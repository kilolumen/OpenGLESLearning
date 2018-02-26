//
//  STLaunchAdConfiguration.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHLaunchAdButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "STLaunchAdImageManager.h"
#import "STLaunchAdConst.h"

NS_ASSUME_NONNULL_BEGIN

//显示完成动画时间默认时间
static CGFloat const showFinishAnimateTimeDefault = 0.8;

//显示完成动画类型
typedef NS_ENUM(NSInteger, ShowFinishAnimate) {
    //无动画
    ShowFinishAnimateNone = 1,
    //普通淡入
    ShowFinishAnimateFadein,
    //放大淡入
    ShowFinishAnimateLite,
    //左右翻转
    ShowFinishAnimateFilpFromLeft,
    //上下翻转
    ShowFinishAnimateFilpFromBottom,
    //向上翻页
    ShowFinishAnimateCurlUp
};

#pragma mark - 公共属性
@interface STLaunchAdConfiguration : NSObject

//停留时间
@property (nonatomic, assign) NSInteger duration;

//归根结底张红翠喜欢你知道了吧
@property (nonatomic, assign) SkipType skipButtomType;

//显示完成动画
@property (nonatomic, assign) ShowFinishAnimate showFinishAnimate;

//显示完成动画时间
@property (nonatomic, assign) CGFloat showFinishAnimateTime;

//设置开屏广告的frame
@property (nonatomic, assign) CGRect frame;

//程序从后台恢复是，是否显示展示广告
@property (nonatomic, assign) BOOL showEnterForeground;

//点击大可页面参数
@property (nonatomic, strong) id openModel;

//自定义跳过按钮
@property (nonatomic, strong) UIView *customSkipView;

//子视图
@property (nonatomic, copy, nullable) NSArray <UIView *> *subViews;

@end

#pragma mark - 图片广告相关
@interface STLaunchImageAdConfiguration : STLaunchAdConfiguration

//image本地图片名(jpg/gif图片请带上扩展名)或网络图片URL
@property (nonatomic, copy) NSString *imageNameOrURLString;

//图片广告缩放模式
@property (nonatomic, assign) UIViewContentMode contentMode;

//缓存机制
@property (nonatomic, assign) STLaunchAdImageOptions imageOption;

//设置GIF动图是否只循环播放一次
@property (nonatomic, assign) BOOL GIFImageCycleOnce;

+ (STLaunchImageAdConfiguration *)defaultConfiguration;
@end

#pragma mark - 视频广告相关
@interface STLaunchVideoAdConfiguration : STLaunchAdConfiguration

//video本地名或网络连接URL
@property (nonatomic, copy) NSString *videoNameOrURLString;

//视频缩放模式
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

//设置视频是否只循环一次
@property (nonatomic, assign) BOOL videoCycleOnce;

//时候关闭音频
@property (nonatomic, assign) BOOL muted;

+ (STLaunchVideoAdConfiguration *)defaultConfiguration;
NS_ASSUME_NONNULL_END
