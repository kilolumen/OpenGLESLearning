//
//  STLaunchAdDownloader.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - STLaunchAdDownload

typedef void(^STLaunchAdDownloadProgressBlock) (unsigned long long total, unsigned long long current);

typedef void(^STLaunchAdDownloadImageCompletedBlock) (UIImage *image, NSData *data, NSError *error);

typedef void(^STLaunchAdDownloadVideoCompletedBlock) (NSURL *location, NSError *error);

typedef void(^STLaunchAdBatchDownloadAndCacheCompletedBlock) (NSArray * completedArray);

@protocol STLaunchAdDownladDelegate <NSObject>

- (void)downloadFinishWithURL:(NSURL *)url;

@end

@interface STLaunchAdDownload : NSObject
@property (nonatomic, assign, nonnull) id<STLaunchAdDownladDelegate> delegate;
@end

@interface STLaunchAdImageDownload : STLaunchAdDownload
@end

@interface STLaunchAdVideoDownload : STLaunchAdDownload
@end

#pragma mark - STLaunchAdDownloader
@interface STLaunchAdDownloader : NSObject

+ (nonnull instancetype)sharedDownloader;

- (void)downloadImageWithURL:(nonnull NSURL *)url
                    progress:(nullable STLaunchAdDownloadProgressBlock)progressBlock
                   completed:(nullable STLaunchAdDownloadImageCompletedBlock)completedBlock;

- (void)downloadImageAndCacheWithURLArray:(nonnull NSArray<NSURL *>*)urlArray;
- (void)downloadImageAndCacheWithURLArray:(nonnull NSArray<NSURL *> *)urlArray
                                completed:(nullable STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock;

- (void)downloadVideoWithURL:(nonnull NSURL *)url
                    progress:(nullable STLaunchAdDownloadProgressBlock)progressBlock
                   completed:(nullable STLaunchAdDownloadVideoCompletedBlock)completedBlock;
- (void)downloadVideoAndCacheWithURLArray:(nonnull NSArray<NSURL *>*)urlArray;
- (void)downloadVideoAndCacheWithURLArray:(nonnull NSArray<NSURL *>*)urlArray
                                completed:(nonnull STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock;
@end
