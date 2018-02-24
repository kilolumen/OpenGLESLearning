//
//  STLaunchAdCache.h
//  STLaunchAdDemo
//
//  Created by 孙健 on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SaveCompletionBlock) (BOOL result, NSURL *URL);

@interface STLaunchAdCache : NSObject

//获取缓存的图片
+ (UIImage *)getCacheImageWithURL:(NSURL *)url;
//同上
+ (NSData *)getCacheImageDataWithURL:(NSURL *)url;
//保存图片
+ (BOOL)saveImageData:(NSData *)data imageURL:(NSURL *)url;
//缓存图片 - 异步
+ (void)async_saveImageData:(NSData *)data
                   imageURL:(NSURL *)url
                  completed:(nullable SaveCompletionBlock)completedBlock;
//检查是否已经存在该图片
+ (BOOL)checkImageInCacheWithURL:(NSURL *)url;
//检查是否已经存在该视频
+ (BOOL)checkVideoInChacheWithURL:(NSURL *)url;
+ (BOOL)checkVideoInCacheWithFileName:(NSString *)videoFileName;
+ (nullable NSURL *)getCacheVideoWithURL:(NSURL *)url;
+ (BOOL)saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url;
+ (void)async_saveVideoAtLocation:(NSURL *)location
                              URL:(NSURL *)url
                        completed:(nullable SaveCompletionBlock)completedBlock;
+ (NSString *)videoPathWithURL:(NSURL *)url;
+ (NSString *)videoPathWithFileName:(NSString *)videoFileName;
+ (void)async_saveImageURL:(NSString *)url;
+ (NSString *)getCacheImageUrl;
+ (void)async_saveVideoUrl:(NSString *)url;
+ (NSString *)stLaunchAdCachePath;
+ (void)clearDiskCache;
+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *>*)imageUrlArray;
+ (void)clearDiskCacheWithExceptImageUrlArray:(NSArray<NSURL *>*)exceptImageUrlArray;
+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *>*)videoArray;
+ (void)clearDiskCacheWithExceptVideoUrlArray:(NSArray<NSURL *>*)exceptVideoArray;
+ (float)diskCacheSize;
+ (NSString *)md5String:(NSString *)string;
@end
NS_ASSUME_NONNULL_END
