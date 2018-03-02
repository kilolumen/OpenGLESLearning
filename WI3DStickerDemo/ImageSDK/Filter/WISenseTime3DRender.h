//
//  WISenseTime3DRender.h
//  Pods
//
//  Created by ycpeng on 2017/10/31.
//  Copyright © 2017年 weibo. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "WISenseTimeFaceConst.h"
#import "WISenseTimeFaceGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface WISenseTime3DRender : GPUImageFilter

@property (nonatomic, strong, nullable) WISenseTimeFaceGroup *faceGroup;

/**
 初始化商汤3D渲染滤镜，可能失败：初始化商汤SDK时遭遇失败

 @return 商汤3D渲染滤镜实例，失败时返回nil
 */
- (nullable instancetype)init;

/**
 设置贴纸素材图像所占用的最大内存

 @param stickerMemory 贴纸素材图像所占用的最大内存（MB）,默认150MB,素材过大时,循环加载,降低内存； 贴纸较小时,全部加载,降低cpu
 @return 设置成功返回YES，失败返回NO
 */
- (BOOL)setStickerMemory:(float)stickerMemory;

/**
 配置3D贴纸

 @param filePath 3D贴纸的文件路径(zip包)
 @param resultBlock 配置结果的回调，param：success是否成功，actionOptions贴纸触发动作的类型
 */
- (void)setStickerWithFilePath:(nullable NSString *)filePath result:(nullable void(^)(BOOL success, WIActionDetectOption actionOptions))resultBlock;

@end

NS_ASSUME_NONNULL_END
