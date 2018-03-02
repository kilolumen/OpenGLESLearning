//
//  WISenseTimeFaceGroup.h
//  ImageSDK
//
//  Created by robbie on 2017/3/26.
//  Copyright © 2017年 weibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "st_mobile_human_action.h"

NS_ASSUME_NONNULL_BEGIN

@class WISenseTimeFaceGroup ;
/**
 * @brief FaceAdapter遵循协议，统一第三方Objective-C接口
 */
@protocol WIFaceDetectionProtocol <NSObject>

/**
 * @brief 通过sampleBuffer获取WIFace对象
 *
 * @param sampleBuffer 采集获取的CMSampleBufferRef对象
 * @param isMirror 是否镜面
 * @return 面部信息
 */
- (WISenseTimeFaceGroup * _Nullable)faceFromCameraSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                                      isMirror:(BOOL)isMirror;

///视频人脸检测方向
@property (assign, nonatomic)UIDeviceOrientation deviceOrientation;

@end

#pragma mark - WISenseTimeFaceGroup
@interface WISenseTimeFaceGroup: NSObject

@property (nonatomic, assign) st_mobile_human_action_t humanAction;

@end

NS_ASSUME_NONNULL_END
