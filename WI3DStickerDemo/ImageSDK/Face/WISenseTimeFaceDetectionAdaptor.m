//
//  WISenseTimeFaceDetectionAdaptor.m
//  Pods
//
//  Created by robbie on 2017/5/19.
//
//

#import "WISenseTimeFaceDetectionAdaptor.h"
#import "WISenseTimeHelper.h"
#import "st_mobile_human_action.h"
#import "st_mobile_common.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///默认脸部最多识别个数
static int8_t const K_DEFAULT_FACE_LIMIT = 4;

@interface WISenseTimeFaceDetectionAdaptor()
{
    st_handle_t _videoTracker;//视频面部识别
    st_handle_t _imageTracker;//图片面部识别
}

@property (nonatomic, assign) WISenseTimeFaceDetectionAdaptorType adaptorType;
@property (nonatomic, assign) WIActionDetectOption actionDetectOptions;

@end

@implementation WISenseTimeFaceDetectionAdaptor


@synthesize deviceOrientation = _deviceOrientation;

- (void)dealloc
{
    [self teardown];
}

- (instancetype)initWithType:(WISenseTimeFaceDetectionAdaptorType)type
{
    self = [super init];
    if(self)
    {
        _adaptorType = type;
        _deviceOrientation = [[UIDevice currentDevice] orientation];
    }
    return self ;
}

- (void)teardown
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    switch (_adaptorType)
    {
        case WISenseTimeFaceDetectionAdaptorTypeImage:
            if (_imageTracker)
            {
                st_mobile_human_action_reset(_imageTracker);
                st_mobile_human_action_destroy(_imageTracker);
                _imageTracker = NULL;
            }
            break;
        case WISenseTimeFaceDetectionAdaptorTypeVideo:
        case WISenseTimeFaceDetectionAdaptorTypeMovie:
            if (_videoTracker)
            {
                st_mobile_human_action_reset(_videoTracker);
                st_mobile_human_action_destroy(_videoTracker);
                _videoTracker = NULL;
            }
            break;
        default:
            break;
    }
    
#endif
}

- (BOOL)setupHandleWithOptions:(WIActionDetectOption)options
{
    self.actionDetectOptions = options;
    
#if (TARGET_IPHONE_SIMULATOR)
    return NO;
#else
    if (![WISenseTimeHelper checkActiveCode])
    {
        return NO;
    }
    
    st_result_t iRet = ST_OK;
    
    //人脸位置信息的检测
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"WeiboImageSDK" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *strModelPath = [sourceBundle pathForResource:@"action" ofType:@"model"];
    
    switch (_adaptorType)
    {
        case WISenseTimeFaceDetectionAdaptorTypeImage:
        {
            uint32_t config = ST_MOBILE_DETECT_MODE_IMAGE | ST_MOBILE_ENABLE_FACE_DETECT;
            
            iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                                 config,
                                                 &_imageTracker);
            
            if (ST_OK != iRet || !_imageTracker)
            {
                return NO;
            }
        }
            break;
        case WISenseTimeFaceDetectionAdaptorTypeVideo:
        case WISenseTimeFaceDetectionAdaptorTypeMovie:
        {
            uint32_t config = ST_MOBILE_DETECT_MODE_VIDEO
            | ST_MOBILE_TRACKING_ENABLE_FACE_ACTION
            | ST_MOBILE_ENABLE_FACE_DETECT;
            
            iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                                 config,
                                                 &_videoTracker);
            
            if (ST_OK != iRet || !_videoTracker)
            {
                return NO;
            }
            
            //防抖动
            if(_videoTracker)
            {
                st_mobile_human_action_setparam(_videoTracker, ST_HUMAN_ACTION_PARAM_SMOOTH_THRESHOLD, 1.0);
                st_mobile_human_action_setparam(_videoTracker, ST_HUMAN_ACTION_PARAM_HEADPOSE_THRESHOLD, 0.0);
            }
        }
            break;
        default:
            break;
    }
    
    [self setFacelimit:K_DEFAULT_FACE_LIMIT];
    
    return YES;
#endif
}

- (void)setFacelimit:(int)limit
{
#if !(TARGET_IPHONE_SIMULATOR)
    switch (_adaptorType)
    {
        case WISenseTimeFaceDetectionAdaptorTypeImage:
        {
            if(_videoTracker)
            {
                st_mobile_human_action_setparam(_imageTracker, ST_HUMAN_ACTION_PARAM_FACELIMIT, limit);
            }
        }
            break;
        case WISenseTimeFaceDetectionAdaptorTypeVideo:
        case WISenseTimeFaceDetectionAdaptorTypeMovie:
        {
            if(_videoTracker)
            {
                st_mobile_human_action_setparam(_videoTracker, ST_HUMAN_ACTION_PARAM_FACELIMIT, limit);
            }
        }
            break;
        default:
            break;
    }
    
#endif
}

#pragma mark - WIFaceDetectionProtocol
- (WISenseTimeFaceGroup * _Nullable)faceFromCameraSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                                      isMirror:(BOOL)isMirror
{
    if (_adaptorType != WISenseTimeFaceDetectionAdaptorTypeVideo)
    {
        return nil;
    }
    return [self faceFromSampleBuffer:sampleBuffer isMirror:isMirror] ;
}

- (WISenseTimeFaceGroup * _Nullable)faceFromSampleBuffer:(CMSampleBufferRef)sampleBuffer isMirror:(BOOL)isMirror
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    return [self faceFromMoviePixelBuffer:pixelBuffer isMirror:isMirror];
}

#pragma mark -
- (WISenseTimeFaceGroup * _Nullable)faceFromMoviePixelBuffer:(CVPixelBufferRef)pixelBuffer isMirror:(BOOL)isMirror
{
#if (TARGET_IPHONE_SIMULATOR)
    return nil;
#else
    
    if (_videoTracker==NULL || !(_adaptorType == WISenseTimeFaceDetectionAdaptorTypeVideo))
    {
        return nil;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
    
    int iWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer,0);
    int iHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer,0);
    int iBytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    
    size_t iTop , iBottom , iLeft , iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    
    iWidth = iWidth + (int)iLeft + (int)iRight;
    iHeight = iHeight + (int)iTop + (int)iBottom;
    
    st_rotate_type stMobileRotate = ST_CLOCKWISE_ROTATE_0;
    CGSize imageSize = CGSizeZero ;
    if (_adaptorType == WISenseTimeFaceDetectionAdaptorTypeVideo)
    {
        imageSize = CGSizeMake(iHeight, iWidth);
        //视频采集
        switch (_deviceOrientation)
        {
            case UIDeviceOrientationPortrait:
            {
                stMobileRotate = ST_CLOCKWISE_ROTATE_90;
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                stMobileRotate = ST_CLOCKWISE_ROTATE_270;
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                stMobileRotate = isMirror ? ST_CLOCKWISE_ROTATE_180 : ST_CLOCKWISE_ROTATE_0;
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                stMobileRotate = isMirror ? ST_CLOCKWISE_ROTATE_0 : ST_CLOCKWISE_ROTATE_180;
            }
                break;
            default:
            {
                stMobileRotate = ST_CLOCKWISE_ROTATE_90;
            }
                break;
        }
    }
    
    st_mobile_human_action_t pFaceActionArray;
    memset(&pFaceActionArray, 0, sizeof(st_mobile_human_action_t));
    
    st_result_t iRet = st_mobile_human_action_detect(_videoTracker,
                                                     baseAddress,
                                                     ST_PIX_FMT_NV12,
                                                     iWidth,
                                                     iHeight,
                                                     iBytesPerRow,
                                                     stMobileRotate,
                                                     _actionDetectOptions,
                                                     &pFaceActionArray);
    
    if (ST_OK != iRet)
    {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return nil;
    }
    
    int iFaceCount = pFaceActionArray.face_count;
    if (iFaceCount == 0)
    {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return nil;
    }
    
    WISenseTimeFaceGroup *group = [[WISenseTimeFaceGroup alloc] init] ;
    group.humanAction = pFaceActionArray;
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return group;
#endif
}

@end

NS_ASSUME_NONNULL_END
