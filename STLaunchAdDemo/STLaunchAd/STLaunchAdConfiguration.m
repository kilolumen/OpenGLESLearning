//
//  STLaunchAdConfiguration.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdConfiguration.h"

#pragma mark - 公共
@implementation STLaunchAdConfiguration

@end

#pragma mark - 图片广告相关
@implementation STLaunchImageAdConfiguration

+ (STLaunchImageAdConfiguration *)defaultConfiguration
{
    //配置广告数据
    STLaunchImageAdConfiguration *configuration = [STLaunchImageAdConfiguration new];
    //广告停留时间
    configuration.duration = 5;
    //广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    //设置GIF动图是否只循环播放一次(仅对动图有效）
    configuration.GIFImageCycleOnce = NO;
    //缓存机制
    configuration.imageOption = STLaunchAdImageDefault;
    //图片填充模式
    configuration.contentMode = UIViewContentModeScaleToFill;
    //广告显示完成动画
    configuration.showFinishAnimate = ShowFinishAnimateFadein;
    //显示完成动画时间
    configuration.showFinishAnimateTime = showFinishAnimateTimeDefault;
    //跳过按钮类型
    configuration.skipButtomType = SkipTypeTimeText;
    //后台返回时，是否显示广告
    configuration.showEnterForeground = NO;
    return configuration;
}


@end

@implementation STLaunchVideoAdConfiguration

+ (STLaunchVideoAdConfiguration *)defaultConfiguration
{
    //配置广告数据
    STLaunchVideoAdConfiguration *configuration = [STLaunchVideoAdConfiguration new];
    //广告停留时间
    configuration.duration = 5;
    //广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    //视频填充模式
    configuration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //是否只播放一次
    configuration.videoCycleOnce = NO;
    //广告显示完成动画
    configuration.showFinishAnimate = ShowFinishAnimateFadein;
    //显示完成动画时间
    configuration.showFinishAnimateTime = showFinishAnimateTimeDefault;
    //跳过按钮类型
    configuration.skipButtomType = SkipTypeTimeText;
    //后台返回时是否显示广告
    configuration.showEnterForeground = NO;
    //时候静音播放
    configuration.muted = NO;
    return configuration;
}
@end

#pragma mark - 视频广告相关
