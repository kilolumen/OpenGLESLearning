//
//  SRTSenseTimeSDKWrapper.m
//  shiritan
//
//  Created by Yangtsing.Zhang on 2018/1/23.
//  Copyright © 2018年 Seamus. All rights reserved.
//

#import "SRTSenseTimeSDKWrapper.h"
#import <CommonCrypto/CommonDigest.h>

//ST_MOBILE
#import "st_mobile_beautify.h"
#import "st_mobile_license.h"

#define ST_FACE_DETECT_VIDEO    (ST_MOBILE_DETECT_MODE_VIDEO | \
                                 ST_MOBILE_ENABLE_FACE_DETECT)

#define ST_FACE_DETECT_IMAGE    (ST_MOBILE_DETECT_MODE_IMAGE | \
                                 ST_MOBILE_ENABLE_FACE_DETECT)
/* 生产*/
#define ST_RED_MAX 0.5
#define ST_BUFFING_MAX 0.7
#define ST_WHITE_MAX 0.3
#define ST_BIG_EYE_MAX 0.15
#define ST_SHRINK_FACE_MAX 0.15
#define ST_SHRINK_JAW_MAX 0.18


// 测试
//#define ST_RED_MAX 0.8
//#define ST_BUFFING_MAX 0.8
//#define ST_WHITE_MAX 0.8
//#define ST_BIG_EYE_MAX 0.1
//#define ST_SHRINK_FACE_MAX 0.2
//#define ST_SHRINK_JAW_MAX 0.6


@interface SRTSenseTimeSDKWrapper(){
    st_handle_t _hDetector; // detector句柄
    st_handle_t _hBeautify; // beautify句柄

}
/************************** 强度调节 begin ****************************/
///磨皮强度 [0,1]
@property (nonatomic, assign) float buffingStrength;
///红润强度 [0,1]
@property (nonatomic, assign) float reddenStrength;
///美白强度 [0,1]
@property (nonatomic, assign) float whiteStrength;
///瘦脸强度 [0,1]
@property (nonatomic, assign) float shrinkFaceStrength;
///大眼强度 [0,1]
@property (nonatomic, assign) float bigEyeStrength;
///小脸(瘦下巴)强度 [0,1]
@property (nonatomic, assign) float shrinkJawStrength;
/************************** 强度调节 end   ****************************/

///人脸检测的配置掩码
@property (nonatomic, assign) NSUInteger faceDetectConfig;

@end

@implementation SRTSenseTimeSDKWrapper

static SRTSenseTimeSDKWrapper *_console;

+ (SRTSenseTimeSDKWrapper *)mainConsole
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _console = [[SRTSenseTimeSDKWrapper alloc] init];
    });
    return _console;
}

- (instancetype)init{
    if (self = [super init]) {
        EAGLSharegroup *glShareGroup = [[[GPUImageContext sharedImageProcessingContext] context] sharegroup];
        _stGLContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2 sharegroup: glShareGroup];
        _inputType = ST_INPUT_TYPE_INVALID;
    }
    return self;
}

- (void)dealloc
{
    _console = nil;
    [self releaseHandles];
    _stGLContext = nil;
    [EAGLContext setCurrentContext: [GPUImageContext sharedImageProcessingContext].context];
    devLog(@"dealloc");
}

- (void)createHandlesOfType:(ST_INPUT_TYPE)type{
    if ([self checkActiveCode] == FALSE) {
        devLog(@"验证商汤License 没有通过");
        return;
    }
    
    st_result_t iRet = ST_OK;
    //[EAGLContext setCurrentContext:self.stGLContext];
//    [GPUImageContext useImageProcessingContext];
    if (_hDetector == NULL) {
        //初始化检测模块句柄
        NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Action_5.2.0" ofType:@"model"];
        
//        uint32_t iConfig = ST_MOBILE_DETECT_MODE_IMAGE;
//        if (type == ST_INPUT_TYPE_VIDEO) {
//            iConfig = ST_MOBILE_DETECT_MODE_VIDEO;
//        }
        uint32_t iConfig = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE;
        if (type == ST_INPUT_TYPE_VIDEO) {
            iConfig = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
        }
        iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                             iConfig,
                                             &_hDetector);
        
        if (ST_OK != iRet || !_hDetector) {
            devLog(@"人脸检测句柄初始化失败");
        }else{
            /*不需要加载这个模型
            NSString *strFaceExtraModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Extra_5.1.0" ofType:@"model"];
            iRet = st_mobile_human_action_add_sub_model(_hDetector, strFaceExtraModelPath.UTF8String);
            
            
            if (iRet != ST_OK) {
                devLog(@"human action add face extra model failed: %d", iRet);
            }
            */
        }
    }
    
    if (_hBeautify == NULL) {
        iRet = st_mobile_beautify_create(&_hBeautify);
        if (ST_OK != iRet || !_hBeautify) {
            devLog(@"美颜句柄初始化失败");
        }else{
            self.skinBeautyStrength = 0.6;
            self.shapeBeautyStrength = 0.6;
            [self applyBeautyParams];
        }
    }
    _inputType = type;
}

- (void)releaseHandles{
    if (_hDetector) {
        st_mobile_human_action_destroy(_hDetector);
        _hDetector = NULL;
    }
    
    if (_hBeautify) {
        st_mobile_beautify_destroy(_hBeautify);
        _hBeautify = NULL;
    }
    
}

- (void)switchHandlesToType:(ST_INPUT_TYPE)type{
    if (type != _inputType) {
        [self releaseHandles];
        [self createHandlesOfType: type];
    }
}

- (void)configOpenGLEnv{
    
}

#pragma mark - check license
//验证license
- (BOOL)checkActiveCode
{
    NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [self getSHA1StringWithData:dataLicense];
    
    st_result_t iRet = ST_OK;
    
    
    if (strStoredSHA1.length > 0 && [strLicenseSHA1 isEqualToString:strStoredSHA1]) {
        
        // Get current active code
        // In this app active code was stored in NSUserDefaults
        // It also can be stored in other places
        NSData *activeCodeData = [userDefaults objectForKey:strKeyActiveCode];
        
        // Check if current active code is available
#if CHECK_LICENSE_WITH_PATH
        
        // use file
        iRet = st_mobile_check_activecode(
                                          strLicensePath.UTF8String,
                                          (const char *)[activeCodeData bytes],
                                          (int)[activeCodeData length]
                                          );
        
#else
        
        // use buffer
        NSData *licenseData = [NSData dataWithContentsOfFile:strLicensePath];
        
        iRet = st_mobile_check_activecode_from_buffer(
                                                      [licenseData bytes],
                                                      (int)[licenseData length],
                                                      [activeCodeData bytes],
                                                      (int)[activeCodeData length]
                                                      );
#endif
        
        
        if (ST_OK == iRet) {
            
            // check success
            return YES;
        }
    }
    
    /*
     1. check fail
     2. new one
     3. update
     */
    
    char active_code[1024];
    int active_code_len = 1024;
    
    // generate one
#if CHECK_LICENSE_WITH_PATH
    
    // use file
    iRet = st_mobile_generate_activecode(
                                         strLicensePath.UTF8String,
                                         active_code,
                                         &active_code_len
                                         );
    
#else
    
    // use buffer
    NSData *licenseData = [NSData dataWithContentsOfFile:strLicensePath];
    
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [licenseData bytes],
                                                     (int)[licenseData length],
                                                     active_code,
                                                     &active_code_len
                                                     );
#endif
    
    if (ST_OK != iRet) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"使用 license 文件生成激活码时失败，可能是授权文件过期。" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
        
    } else {
        
        // Store active code
        NSData *activeCodeData = [NSData dataWithBytes:active_code length:active_code_len];
        
        [userDefaults setObject:activeCodeData forKey:strKeyActiveCode];
        [userDefaults setObject:strLicenseSHA1 forKey:strKeySHA1];
        
        [userDefaults synchronize];
    }
    
    return YES;
}

- (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

#pragma mark - Outside method
- (void)detectFaceInImage:(const unsigned char *)p_image width:(int)imgWidth height:(int)imgHeight bytesPerRow:(int)byteNumPerRow rotation:(GPUImageRotationMode)rotation detectRet:(st_mobile_human_action_t *)detectRet{
    
    st_rotate_type st_rotation = [self convertToStRotation: rotation];
    st_result_t iRet = ST_OK;
    
    uint32_t detectConfig = ST_MOBILE_FACE_DETECT;
    iRet = st_mobile_human_action_detect(_hDetector,
                                         p_image,
                                         ST_PIX_FMT_RGBA8888,
                                         imgWidth,
                                         imgHeight,
                                         byteNumPerRow,
                                         st_rotation,
                                         detectConfig,
                                         detectRet);
    if (iRet != ST_OK) {
        devLog(@"商汤人脸检测接口返回了失败");
    }
    
}

- (void)beautifyTexture:(GLuint)originTexture retTexture:(GLuint)retTexture width:(int)width height:(int)height faceDetectRet:(st_mobile_human_action_t *)p_faceDetectRet{    
    //调用SenseTimeSDK美颜接口
    [self useSensetimeGLContext];
    
    st_result_t iRet = ST_OK;
    iRet = st_mobile_beautify_process_texture(_hBeautify,
                                              originTexture,
                                              width,
                                              height,
                                              p_faceDetectRet,
                                              retTexture,
                                              p_faceDetectRet);
    if (iRet != ST_OK) {
        devLog(@"商汤美颜接口返回了失败");
    }
}

- (void)useSensetimeGLContext{
    if ([EAGLContext currentContext] != _stGLContext) {
        [EAGLContext setCurrentContext: _stGLContext];
    }
}

#pragma mark - Inner Logic
///应用用户设置的各项美颜参数
- (void)applyBeautyParams{
    st_result_t iRet = ST_OK;
    
    //红润
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.reddenStrength);
    if (iRet != ST_OK) {
        devLog(@"应用红润参数失败");
    }
    
    //磨皮
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.buffingStrength);
    if (iRet != ST_OK) {
        devLog(@"应用磨皮参数失败");
    }
    
    //大眼
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.bigEyeStrength);
    if (iRet != ST_OK) {
        devLog(@"应用大眼参数失败");
    }
    
    //瘦脸
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.shrinkFaceStrength);
    if (iRet != ST_OK) {
        devLog(@"应用瘦脸参数失败");
    }
    
    //小脸
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.shrinkJawStrength);
    if (iRet != ST_OK) {
        devLog(@"应用小脸参数失败");
    }
    
    //美白
    iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.whiteStrength);
    if (iRet != ST_OK) {
        devLog(@"应用美白参数失败");
    }
    
}

- (st_rotate_type)convertToStRotation:(GPUImageRotationMode)rotation{
    st_rotate_type st_rotation = ST_CLOCKWISE_ROTATE_0;
    switch (rotation) {
        case kGPUImageRotateLeft:{
            st_rotation = ST_CLOCKWISE_ROTATE_90;
        }break;
        
        case kGPUImageRotateRight:{
            st_rotation = ST_CLOCKWISE_ROTATE_270;
        }break;
            
        case kGPUImageRotate180:{
            st_rotation = ST_CLOCKWISE_ROTATE_180;
        }break;
            
        default:
            break;
    }
    return st_rotation;
}

#pragma mark - Setters
///只对外暴露美颜、美肌两个强度设置接口，再x上一个控制值之后传递给商汤SDK
- (void)setSkinBeautyStrength:(float)skinBeautyStrength{
    _buffingStrength = skinBeautyStrength * ST_BUFFING_MAX;
    _whiteStrength = skinBeautyStrength * ST_WHITE_MAX;
    _reddenStrength = skinBeautyStrength * ST_RED_MAX;
    
    _skinBeautyStrength = skinBeautyStrength;
}

- (void)setShapeBeautyStrength:(float)shapeBeautyStrength{
    _shrinkFaceStrength = shapeBeautyStrength * ST_SHRINK_FACE_MAX;
    _shrinkJawStrength = shapeBeautyStrength * ST_SHRINK_JAW_MAX;
    _bigEyeStrength = shapeBeautyStrength * ST_BIG_EYE_MAX;
    
    _shapeBeautyStrength = shapeBeautyStrength;
}

#pragma mark - Getters
- (st_handle_t)faceDetectHandle{
    return _hDetector;
}

@end
