//
//  STLaunchAd.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAd.h"
#import "STLaunchAdView.h"
#import "STLaunchAdImageView+STLaunchAdCache.h"
#import "STLaunchAdDownloader.h"
#import "STLaunchAdCache.h"
#import "FLAnimatedImage.h"
#import "STLaunchAdController.h"

typedef NS_ENUM(NSInteger, STLaunchAdType) {
    STLaunchAdTypeImage,
    STLaunchAdTypeVideo
};

static NSInteger defaultWaitDataDuration = 3;
static SourceType _sourceType = SourceTypeLaunchImage;

@interface STLaunchAd ()
@property (nonatomic, assign) STLaunchAdType launchAdType;
@property (nonatomic, assign) NSInteger waitDataDuration;
@property (nonatomic, strong) STLaunchImageAdConfiguration *imageAdConfiguration;
@property (nonatomic, strong) STLaunchVideoAdConfiguration *videoAdConfiguration;
@property (nonatomic, strong) XHLaunchAdButton *skipButton;
@property (nonatomic, strong) STLaunchadVideoView *adVideoView;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, copy)   dispatch_source_t waitDataTmer;
@property (nonatomic, copy)   dispatch_source_t skipTimer;
@property (nonatomic, assign) BOOL detailPageShowing;
@property (nonatomic, assign) CGPoint clickPoint;
@end

@implementation STLaunchAd
+ (void)setLaunchSourceType:(SourceType)sourceType
{
    _sourceType = sourceType;
}

+ (void)setWaitDataDuration:(NSInteger)waitDataDuration
{
    STLaunchAd *launchAd = [STLaunchAd shareLaunchAd];
    launchAd.waitDataDuration = waitDataDuration;
}

+ (STLaunchAd *)imageAdWithImageAdConfiguration:(STLaunchAdConfiguration *)imageAdConfiguration
{
    return [STLaunchAd imageAdWithImageAdConfiguration:imageAdConfiguration delegate:nil];
}

+ (STLaunchAd *)imageAdWithImageAdConfiguration:(STLaunchImageAdConfiguration *)imageAdConfiguration delegate:(id)delegate
{
    STLaunchAd *launchAd = [STLaunchAd shareLaunchAd];
    if (delegate) launchAd.delegate = delegate;
    launchAd.imageAdConfiguration = imageAdConfiguration;
}

+ (STLaunchAd *)videoAdWithVideoAdConfiguration:(STLaunchAdConfiguration *)videoAdconfigutration
{
    return [STLaunchAd videoAdWithVideoAdConfiguration:videoAdconfigutration delegate:nil];
}

+ (STLaunchAd *)videoAdWithVideoAdConfiguration:(STLaunchVideoAdConfiguration *)videoAdconfigutration delegate:(nullable id)delegate
{
    STLaunchAd *launcdAd = [STLaunchAd shareLaunchAd];
    if(delegate) launcdAd.delegate = delegate;
    launcdAd.videoAdConfiguration = videoAdconfigutration;
}

+ (void)downloadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray
{
    [self downloadImageAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downloadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray completed:(STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock
{
    if(urlArray.count == 0) return;
    [[STLaunchAdDownloader sharedDownloader] downloadImageAndCacheWithURLArray:urlArray completed:completedBlock];
}

+ (BOOL)checkImageInCacheWithURL:(NSURL *)url
{
    return [STLaunchAdCache checkImageInCacheWithURL:url];
}

+ (BOOL)checkVideoInCacheWithURL:(NSURL *)url
{
    return [STLaunchAdCache checkVideoInChacheWithURL:url];
}

+ (void)clearDiskCache
{
    [STLaunchAdCache clearDiskCache];
}

+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray
{
    [STLaunchAdCache clearDiskCacheWithImageUrlArray:imageUrlArray];
}

+ (void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray
{
    [STLaunchAdCache clearDiskCacheWithExceptImageUrlArray:exceptImageUrlArray];
}

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray
{
    [STLaunchAdCache clearDiskCacheWithVideoUrlArray:videoUrlArray];
}

+ (void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray
{
    [STLaunchAdCache clearDiskCacheWithExceptVideoUrlArray:exceptVideoUrlArray];
}

+ (float)diskCacheSize
{
    return [STLaunchAdCache diskCacheSize];
}

+ (NSString *)stLaunchAdCachePath
{
    return [STLaunchAdCache stLaunchAdCachePath];
}

+ (NSString *)cacheImageURLString
{
    return [STLaunchAdCache getCacheImageUrl];
}

+ (NSString *)cacheVideoURLString
{
    return [STLaunchAdCache getCacheVideoUrl];
}

+ (void)removeAnaAnimated:(BOOL)animated
{
    [[STLaunchAd shareLaunchAd] removeAdAnimated:animated];
}

+ (STLaunchAd *)shareLaunchAd
{
    static STLaunchAd *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STLaunchAd alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupLaunchAd];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setupLaunchAdEnterForeground];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:STLaunchAdDetailPageWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            _detailPageShowing = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:STLaunchAdVideoCyclyOnceFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            _detailPageShowing = NO;
        }];
    }
    return self;
}

- (void)setupLaunchAd
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [STLaunchAdController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _window = window;
    [_window addSubview:[[STLaunchImageView alloc] initWithSourceType:_sourceType]];
}

- (void)setupImageAdForConfiguration:(STLaunchImageAdConfiguration *)configuration
{
    if (_window == nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    STLaunchAdImageView *adImageView = [[STLaunchAdImageView alloc] init];
    [_window addSubview:adImageView];
    if(configuration.frame.size.width > 0 &&
       configuration.frame.size.height > 0)
        adImageView.frame = configuration.frame;
    if(configuration.contentMode) adImageView.contentMode = configuration.contentMode;
    if (configuration.imageNameOrURLString.length && STISURLString(configuration.imageNameOrURLString)) {
        [STLaunchAdCache async_saveImageURL:configuration.imageNameOrURLString];
        if ([self.delegate respondsToSelector:@selector(stLaunchAd:launchAdImageView:URL:)]) {
            [self.delegate stLaunchAd:self launchAdImageView:adImageView URL:[NSURL URLWithString:configuration.imageNameOrURLString]];
        }else{
            if (!configuration.imageOption) configuration.imageOption = STLaunchAdImageDefault;
            STWeakSelf
            [adImageView st_setImageWithURL:[NSURL URLWithString:configuration.imageNameOrURLString] placeholderImage:nil GIFImageCycleOnce:configuration.GIFImageCycleOnce options:configuration.imageOption GIFImageCycleOnceFinish:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:STLaunchAdGIFImageCycleOnceFinishNotification object:nil userInfo:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
            } completed:^(UIImage *image, NSData *imageData, NSError *error, NSURL *imageURL) {
                if (!error) {
                    if ([weakSelf.delegate respondsToSelector:@selector(stLaunchad:imageDownloadFinish:imageData:)]) {
                        [weakSelf.delegate stLaunchad:self imageDownloadFinish:image imageData:imageData];
                    }
                }
            }];
            if (configuration.imageOption == STLaunchAdImageCacheInBackground) {
                //缓存中未有
                if (![STLaunchAdCache checkImageInCacheWithURL:[NSURL URLWithString:configuration.imageNameOrURLString]]) {
                    [self removeAndAnimateDefault];
                }
            }
        }
    }else{
        if (configuration.imageNameOrURLString.length) {
            NSData *data = STDataWithFileName(configuration.imageNameOrURLString);
            if (STISGIFTypeWithData(data)) {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                adImageView.animatedImage = image;
                adImageView.image = nil;
                __weak typeof(adImageView) w_adImageView = adImageView;
                adImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if (configuration.GIFImageCycleOnce) {
                        [w_adImageView stopAnimating];
                        STLaunchAdLog(@"GIF不循环，播放完成");
                        [[NSNotificationCenter defaultCenter] postNotificationName:STLaunchAdGIFImageCycleOnceFinishNotification object:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
                    }
                };
            }else{
                adImageView.animatedImage = nil;
                adImageView.image = [UIImage imageWithData:data];
            }
        }else{
            STLaunchAdLog(@"未设置广告图片");
        }
    }
    //skipButton
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispatchTimer];
    //customView
    if (configuration.subViews.count > 0) [self addSubViews:configuration.subViews];
    STWeakSelf
    adImageView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

- (void)addSkipButtonForConfiguration:(STLaunchAdConfiguration *)configuration
{
    if (!configuration.duration) configuration.duration = 5;
    if (!configuration.skipButtomType)  configuration.skipButtomType = SkipTypeTimeText;
    if (configuration.customSkipView) {
        [_window addSubview:configuration.customSkipView];
    }else{
        if (_skipButton == nil) {
            _skipButton = [[XHLaunchAdButton alloc] initWithSkipType:configuration.skipButtomType];
            _skipButton.hidden = YES;
            [_skipButton addTarget:self action:@selector(skipButtomClick) forControlEvents:UIControlEventTouchUpInside];
        }
        [_window addSubview:_skipButton];
        [_skipButton setTitleWithSkipType:configuration.skipButtomType duration:configuration.duration];
    }
}

- (void)setupVideoAdForConfiguration:(STLaunchVideoAdConfiguration *)configuration
{
    if(_window == nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    if(!_adVideoView){
        _adVideoView = [[STLaunchadVideoView alloc] init];
    }
    [_window addSubview:_adVideoView];
    //frame
    if (configuration.frame.size.width > 0 && configuration.frame.size.height > 0) _adVideoView.frame = configuration.frame;
    if (configuration.videoGravity) _adVideoView.videoGravity = configuration.videoGravity;
    _adVideoView.videoCyclyOnce = configuration.videoCycleOnce;
    if (configuration.videoCycleOnce) {
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            STLaunchAdLog(@"video不循环，播放完成");
            [[NSNotificationCenter defaultCenter] postNotificationName:STLaunchAdVideoCyclyOnceFinishNotification object:nil userInfo:@{@"videoNameOrlRLString":configuration.videoNameOrURLString}];
        }];
    }
    
    //数据源
    if (configuration.videoNameOrURLString.length && STISURLString(configuration.videoNameOrURLString)) {
        [STLaunchAdCache async_saveVideoUrl:configuration.videoNameOrURLString];
        
    }
}

- (void)setupLaunchAdEnterForeground
{
    switch (_launchAdType) {
        case STLaunchAdTypeImage:
            if(!_imageAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupImageAdForConfiguration:_imageAdConfiguration];
            break;
        case STLaunchAdTypeVideo:
            if(!_videoAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupVideoAdForConfiguration:_videoAdConfiguration];
            break;
        default:
            break;
    }
}

- (void)removeAdAnimated:(BOOL)animated
{
//    if(animated){
//        [self removeAndAnimate];
//    }else{
//        [self remove];
//    }
}

- (void)removeAndAnimateDefault
{
    STLaunchAdConfiguration *configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if (configuration.showFinishAnimateTime > 0) duration = configuration.showFinishAnimateTime;
    [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
        _window.alpha = 0;
    } completion:^(BOOL finished) {
        [self remove];
    }];
}

- (void)removeSubViewsExceptLaunchAdImageView
{
    
}
@end
