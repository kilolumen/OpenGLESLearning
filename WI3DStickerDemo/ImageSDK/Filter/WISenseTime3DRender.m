//
//  WISenseTime3DRender.m
//  Pods
//
//  Created by ycpeng on 2017/10/31.
//  Copyright © 2017年 weibo. All rights reserved.
//  一招鲜吃遍天

#import "WISenseTime3DRender.h"
#import "st_mobile_sticker.h"
#import "st_mobile_common.h"
#import "WISenseTimeHelper.h"
#import "WISenseTimeFaceGroup.h"

#define TIMELOG(key) double key = CFAbsoluteTimeGetCurrent();
#define TIMEPRINT(key , dsc) printf("%s\t%.1f ms\n" , dsc , (CFAbsoluteTimeGetCurrent() - key) * 1000);

NS_ASSUME_NONNULL_BEGIN

@interface WISenseTime3DRender ()
{
    st_handle_t _hSticker;
    
    CVOpenGLESTextureCacheRef _cvTextureCache;
    
    CVOpenGLESTextureRef _cvTextureOrigin;
    CVOpenGLESTextureRef _cvTextureSticker;
    CVPixelBufferRef _cvStickerBuffer;
    
    GLuint _textureOriginInput;
    GLuint _textureStickerOutput;
}

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation WISenseTime3DRender

- (void)dealloc
{
    if (_hSticker)
    {
        st_mobile_sticker_destroy(_hSticker);
        _hSticker = NULL;
    }
}

- (nullable instancetype)init
{
    self = [super init];
    if (self) {
        if (![self setupHandle])
        {
            return nil;
        }
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:[GPUImageContext sharedImageProcessingContext].context.sharegroup];
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_cvTextureCache);
        if (err)
        {
            NSLog(@"CVOpenGLESTextureCacheCreate %d" , err);
        }
        
        [self setupTextureWithPixelBuffer:&_cvStickerBuffer
                                    width:720.0
                                   height:1280.0
                                glTexture:&_textureStickerOutput
                                cvTexture:&_cvTextureSticker];
    }
    return self;
}

- (BOOL)setupHandle
{
#if (TARGET_IPHONE_SIMULATOR)
    return NO;
#else
    if (![WISenseTimeHelper checkActiveCode])
    {
        return NO;
    }
    
    st_result_t iRet = st_mobile_sticker_create(NULL , &_hSticker);
    
    if (ST_OK != iRet || !_hSticker)
    {
        return NO;
    }else{
//        iRet = st_mobile_sticker_set_waiting_material_loaded(_hSticker, true);
//        if (iRet != ST_OK)
//        {
//            NSLog(@"st_mobile_sticker_set_waiting_material_loaded failed: %d", iRet);
//            return NO;
//        }
        
        //声音贴纸回调，图片版可以不设置
        //        st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound_pic, play_sound_pic, stop_sound_pic);
        
        return YES;
    }
#endif
}

- (BOOL)setStickerMemory:(float)stickerMemory
{
    st_result_t iRet = st_mobile_sticker_set_max_imgmem(_hSticker, stickerMemory);
    if (iRet != ST_OK)
    {
        NSLog(@"st_mobile_sticker_set_max_imgmem failed: %d", iRet);
        return NO;
    }
    return YES;
}

- (void)setStickerWithFilePath:(nullable NSString *)filePath result:(nullable void(^)(BOOL success, WIActionDetectOption actionOptions))resultBlock
{
    // 获取触发动作类型
    WIActionDetectOption iAction = WIActionDetectOptionNone;
    st_result_t iRet = st_mobile_sticker_change_package(_hSticker, filePath.UTF8String);
    if (iRet != ST_OK)
    {
        NSLog(@"st_mobile_sticker_change_package error %d" , iRet);
        !resultBlock?:resultBlock(NO, WIActionDetectOptionNone);
    }
    else
    {
        if (filePath.length > 0) {
            iRet = st_mobile_sticker_get_trigger_action(_hSticker, &iAction);
            if (ST_OK != iRet)
            {
                NSLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
                !resultBlock?:resultBlock(NO, WIActionDetectOptionNone);
            }
            !resultBlock?:resultBlock(YES, iAction);
        }
    }
}

- (void)setFaceGroup:(WISenseTimeFaceGroup * _Nullable)faceGroup
{
    _faceGroup = faceGroup;
}

void item_callback(const char* material_name, st_material_status status) {
    
    switch (status){
        case ST_MATERIAL_BEGIN:
            NSLog(@"begin %s" , material_name);
            break;
        case ST_MATERIAL_END:
            NSLog(@"end %s" , material_name);
            break;
        case ST_MATERIAL_PROCESS:
            NSLog(@"process %s", material_name);
            break;
        default:
            NSLog(@"error");
            break;
    }
}

- (void)handleSkipOrFailedWhenRenderWithSenseTime
{
    if (usingNextFrameForImageCapture)
    {
        [firstInputFramebuffer lock];
    }
    
    // 直接用输入作为输出
    outputFramebuffer = firstInputFramebuffer;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    st_mobile_human_action_t detectResult = _faceGroup.humanAction;
    
    if (detectResult.face_count == 0)
    {
        [self handleSkipOrFailedWhenRenderWithSenseTime];
    }
    else
    {
        
        for (int idx = 0; idx < detectResult.face_count; idx++) {
            st_mobile_106_t p_face = detectResult.p_faces[idx].face106;
            st_pointf_t *points_array = detectResult.p_faces[idx].face106.points_array;
            for (int jdx = 0; jdx < 106; jdx++) {
                NSUInteger mirrorIndex = [WISenseTime3DRender exchangeMirrorIndex:jdx];
                st_pointf_t point = points_array[mirrorIndex];
                p_face.points_array[jdx].x = point.y;
                p_face.points_array[jdx].y = point.x;
            }
            detectResult.p_faces[idx].face106 = p_face;
        }
        
        [self setupOriginTexture];
        
        if ([EAGLContext currentContext] != self.context)
        {
            [EAGLContext setCurrentContext:self.context];
        }
        
        TIMELOG(stickerProcessKey);
        st_result_t iRet = st_mobile_sticker_process_texture(_hSticker,
                                                             _textureOriginInput,
                                                             inputTextureSize.width,
                                                             inputTextureSize.height,
                                                             ST_CLOCKWISE_ROTATE_180,
                                                             false,
                                                             &detectResult,
                                                             item_callback,
                                                             _textureStickerOutput);
        TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:")
        
        if (ST_OK != iRet)
        {
            NSLog(@"st_mobile_sticker_process_texture %d" , iRet);
            [self handleSkipOrFailedWhenRenderWithSenseTime];
        }
        else
        {
            [GPUImageContext useImageProcessingContext];
            
            [GPUImageContext setActiveShaderProgram:filterProgram];
            
            outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
            [outputFramebuffer activateFramebuffer];
            if (usingNextFrameForImageCapture)
            {
                [outputFramebuffer lock];
            }
            
            [self setUniformsForProgramAtIndex:0];
            
            glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
            glClear(GL_COLOR_BUFFER_BIT);
            
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, _textureStickerOutput);
            
            glUniform1i(filterInputTextureUniform, 2);
            
            glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
            glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            [firstInputFramebuffer unlock];
        }
    }
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
    CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
}

- (BOOL)setupOriginTexture
{
    CVPixelBufferRef pixelBuffer = [firstInputFramebuffer pixelFramebuffer];
    
    glFlush();
    
    CVReturn cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _cvTextureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  inputTextureSize.width,
                                                                  inputTextureSize.height,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &_cvTextureOrigin);
    
    if (!_cvTextureOrigin || kCVReturnSuccess != cvRet)
    {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        return NO;
    }
    
    _textureOriginInput = CVOpenGLESTextureGetName(_cvTextureOrigin);
    glBindTexture(GL_TEXTURE_2D , _textureOriginInput);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}

- (BOOL)setupTextureWithPixelBuffer:(CVPixelBufferRef *)pixelBufferOut
                              width:(int)iWidth
                             height:(int)iHeight
                          glTexture:(GLuint *)glTexture
                          cvTexture:(CVOpenGLESTextureRef *)cvTexture
{
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault,
                                               NULL,
                                               NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                             1,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn cvRet = CVPixelBufferCreate(kCFAllocatorDefault,
                                         iWidth,
                                         iHeight,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         pixelBufferOut);
    
    if (kCVReturnSuccess != cvRet)
    {
        NSLog(@"CVPixelBufferCreate %d" , cvRet);
    }
    
    cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         _cvTextureCache,
                                                         *pixelBufferOut,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         iWidth,
                                                         iHeight,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         cvTexture);
    
    CFRelease(attrs);
    CFRelease(empty);
    
    if (kCVReturnSuccess != cvRet)
    {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        return NO;
    }
    
    *glTexture = CVOpenGLESTextureGetName(*cvTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(*cvTexture), *glTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}

#pragma mark - Utils
static NSDictionary<NSNumber * , NSNumber *> *const kMirrorFaceDictionary()
{
    return @{@(0):@(32),@(1):@(31),@(2):@(30),@(3):@(29),@(4):@(28),@(5):@(27),@(6):@(26),@(7):@(25),@(8):@(24),@(9):@(23),@(10):@(22),@(11):@(21),@(12):@(20),@(13):@(19),@(14):@(18),@(15):@(17),@(16):@(16),@(17):@(15),@(18):@(14),@(19):@(13),@(20):@(12),@(21):@(11),@(22):@(10),@(23):@(9),@(24):@(8),@(25):@(7),@(26):@(6),@(27):@(5),@(28):@(4),@(29):@(3),@(30):@(2),@(31):@(1),@(32):@(0),@(33):@(42),@(34):@(41),@(35):@(40),@(36):@(39),@(37):@(38),@(38):@(37),@(39):@(36),@(40):@(35),@(41):@(34),@(42):@(33),@(43):@(43),@(44):@(44),@(45):@(45),@(46):@(46),@(47):@(51),@(48):@(50),@(49):@(49),@(50):@(48),@(51):@(47),@(52):@(61),@(53):@(60),@(54):@(59),@(55):@(58),@(56):@(63),@(57):@(62),@(58):@(55),@(59):@(54),@(60):@(53),@(61):@(52),@(62):@(57),@(63):@(56),@(64):@(71),@(65):@(70),@(66):@(69),@(67):@(68),@(68):@(67),@(69):@(66),@(70):@(65),@(71):@(64),@(72):@(75),@(73):@(76),@(74):@(77),@(75):@(72),@(76):@(73),@(77):@(74),@(78):@(79),@(79):@(78),@(80):@(81),@(81):@(80),@(82):@(83),@(83):@(82),@(84):@(90),@(85):@(89),@(86):@(88),@(87):@(87),@(88):@(86),@(89):@(85),@(90):@(84),@(91):@(95),@(92):@(94),@(93):@(93),@(94):@(92),@(95):@(91),@(96):@(100),@(97):@(99),@(98):@(98),@(99):@(97),@(100):@(96),@(101):@(103),@(102):@(102),@(103):@(101),@(104):@(105),@(105):@(104)};
}

+ (NSUInteger)exchangeMirrorIndex:(NSUInteger)index
{
    static NSDictionary<NSNumber * , NSNumber *> *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = kMirrorFaceDictionary();
    });
    NSNumber *exchangeIndexNumber = dict[@(index)];
    NSAssert(exchangeIndexNumber!=nil, @"index不属于106个人脸范围");
    if (exchangeIndexNumber)
    {
        return [exchangeIndexNumber unsignedIntegerValue];
    }
    return NSUIntegerMax;
}

@end

NS_ASSUME_NONNULL_END
