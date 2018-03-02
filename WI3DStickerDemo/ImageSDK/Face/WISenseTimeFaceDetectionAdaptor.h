//
//  WISenseTimeFaceDetectionAdaptor.h
//  Pods
//
//  Created by robbie on 2017/5/19.
//
//

#import <Foundation/Foundation.h>
#import "WISenseTimeFaceConst.h"
#import "WISenseTimeFaceGroup.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WISenseTimeFaceDetectionAdaptorType) {
    WISenseTimeFaceDetectionAdaptorTypeImage,
    WISenseTimeFaceDetectionAdaptorTypeVideo,
    WISenseTimeFaceDetectionAdaptorTypeMovie,
};

@interface WISenseTimeFaceDetectionAdaptor : NSObject<WIFaceDetectionProtocol>

- (instancetype)initWithType:(WISenseTimeFaceDetectionAdaptorType)type;


/**
 * @brief 配置脸部最多识别个数
 *
 * @param limit 最多脸部个数 默认为4
 *
 */
- (void)setFacelimit:(int)limit;

/**
 * @brief 释放资源
 */
- (void)teardown;

/**
 * @brief 初始化脸部识别句柄
 * @param options 配置需要检测的脸部动作
 * @return 成功返回YES，失败返回NO
 */
- (BOOL)setupHandleWithOptions:(WIActionDetectOption)options;

@end

NS_ASSUME_NONNULL_END
