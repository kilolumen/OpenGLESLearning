//
//  STLaunchAd.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STLaunchAdConfiguration.h"
#import "STLaunchAdConst.h"
#import "STLaunchImageView.h"

NS_ASSUME_NONNULL_BEGIN

@class STLaunchAd;
@protocol STLaunchAdDelegate <NSObject>
@optional
- (void)stLaunchAd:(STLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint;

- (void)stLaunchad:(STLaunchAd *)launchAd imageDownloadFinish:(UIImage *)image imageData:(NSData *)imageData;

- (void)stLaunchAd:(STLaunchAd *)launchAd videoDownladFinish:(NSURL *)pathURL;

- (void)stLaunchad:(STLaunchAd *)launchAd videoDownloadProgress:(float)progress total:(unsigned long long)total current:(unsigned long long)current;

- (void)stLaunchAd:(STLaunchAd *)launchAd customSkipView:(UIView *)customSkipView duration:(NSInteger)duration;

- (void)stLaunchAdShowFinish:(STLaunchAd *)launchAd;

- (void)stLaunchAd:(STLaunchAd *)launchAd launchAdImageView:(UIImageView *)launchAdImageView URL:(NSURL *)url;

@end

@interface STLaunchAd : NSObject

@property (nonatomic, assign) id<STLaunchAdDelegate> delegate;

+ (void)setLaunchSourceType:(SourceType)sourceType;

+ (void)setWaitDataDuration:(NSInteger)waitDataDuration;

+ (STLaunchAd *)imageAdWithImageAdConfiguration:(STLaunchAdConfiguration *)imageAdConfiguration;

+ (STLaunchAd *)imageAdWithImageAdConfiguration:(STLaunchAdConfiguration *)imageAdConfiguration delegate:(nullable id)delegate;

+ (STLaunchAd *)videoAdWithVideoAdConfiguration:(STLaunchAdConfiguration *)videoAdconfigutration;


+ (STLaunchAd *)videoAdWithVideoAdConfiguration:(STLaunchAdConfiguration *)videoAdconfigutration delegate:(nullable id)delegate;

#pragma makr - 批量下载并缓存
+ (void)downloadImageAndCacheWithURLArray:(NSArray <NSURL *>*)urlArray;

+ (void)downloadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray completed:(nullable STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock;

+ (void)downloadVideoAndCacheWithURLArray:(NSArray <NSURL *>*)urlArray;

+ (void)downloadVideoAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray completed:(STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock;

+ (void)removeAnaAnimated:(BOOL)animated;

#pragma mark - 是否已缓存
+ (BOOL)checkImageInCacheWithURL:(NSURL *)url;

+ (BOOL)checkVideoInCacheWithURL:(NSURL *)url;

+ (NSString *)cacheImageURLString;

+ (NSString *)cacheVideoURLString;

+ (void)clearDiskCache;

+ (void)clearDiskCacheWithImageUrlArray:(NSArray <NSURL *>*)imageUrlArray;

+ (void)clearDiskCacheExceptImageUrlArray:(NSArray <NSURL *>*)exceptImageUrlArray;

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray <NSURL *> *)videoUrlArray;

+ (void)clearDiskCacheExceptVideoUrlArray:(NSArray <NSURL *>*)exceptVideoUrlArray;

+ (float)diskCacheSize;

+ (NSString *)stLaunchAdCachePath;

@end
NS_ASSUME_NONNULL_END
