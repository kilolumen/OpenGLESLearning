//
//  STLaunchAdView.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
#import <FLAnimationImage/FLAnimatedImage.h>
#else
#import "FLAnimatedImage.h"
#endif

#if __has_include(<FLAnimatedImage/FLAnimatedImageView.h>)
#import <FLAnimationImage/FLAnimatedImageView.h>
#else
#import "FLAnimatedImageView.h"
#endif

#pragma mark - image
@interface STLaunchAdImageView : FLAnimatedImageView
@property (nonatomic, copy) void(^click)(CGPoint point);
@end

#pragma mark - video
@interface STLaunchadVideoView : UIView
@property (nonatomic, copy) void(^click)(CGPoint point);
@property (nonatomic, strong) AVPlayerViewController *videoPlayer;
@property (nonatomic, assign) MPMovieScalingMode videoScalingMode;
@property (nonatomic, assign) AVLayerVideoGravity videoGravity;
@property (nonatomic, assign) BOOL videoCyclyOnce;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, strong) NSURL *contentURL;

- (void)stopVideoPlayer;

@end
