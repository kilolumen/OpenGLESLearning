//
//  STLaunchAdImageManager.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdImageManager.h"
#import "STLaunchAdCache.h"

@interface STLaunchAdImageManager ()
@property (nonatomic, strong) STLaunchAdDownloader *downloader;
@end

@implementation STLaunchAdImageManager
+ (instancetype)shareManager
{
    static STLaunchAdImageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STLaunchAdImageManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloader = [STLaunchAdDownloader sharedDownloader];
    }
    return self;
}

- (void)loadImageWithURL:(NSURL *)url options:(STLaunchAdImageOptions)options progress:(STLaunchAdDownloadProgressBlock)progresBlock completed:(STExternalCompletionBlock)completedBlock
{
    if(!options) options = STLaunchAdImageDefault;
    if (options & STLaunchAdImageOnlyLoad) {//只下载，不缓存
        [_downloader downloadImageWithURL:url progress:progresBlock completed:^(UIImage *image, NSData *data, NSError *error) {
            if (completedBlock) {
                completedBlock(image, data, error, url);
            }
        }];
    }else if (options & STLaunchAdImageRefreshCached){//有缓存，读缓存，没有缓存，下载更新缓存
        NSData *data = [STLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image && completedBlock) {
            completedBlock(image, data, nil, url);
        }
        [_downloader downloadImageWithURL:url progress:progresBlock completed:^(UIImage *image, NSData *data, NSError *error) {
            if(completedBlock) completedBlock(image, data, error, url);
            [STLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
        }];
    }else if (options & STLaunchAdImageCacheInBackground){//后台刷新
        NSData *data = [STLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image && completedBlock) {
            completedBlock(image, data, nil, url);
        }else{
            [_downloader downloadImageWithURL:url progress:progresBlock completed:^(UIImage *image, NSData *data, NSError *error) {
                [STLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
            }];
        }
    }else{
        NSData *data = [STLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image && completedBlock) {
            completedBlock(image, data, nil, url);
        }else{
            [_downloader downloadImageWithURL:url progress:progresBlock completed:^(UIImage *image, NSData *data, NSError *error) {
                if (completedBlock) {
                    completedBlock(image, data, error, url);
                }
                [STLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
            }];
        }
    }
}
@end
