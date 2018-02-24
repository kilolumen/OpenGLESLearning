//
//  STLaunchAdCache.m
//  STLaunchAdDemo
//
//  Created by 孙健 on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "STLaunchAdConst.h"

@implementation STLaunchAdCache

+ (UIImage *)getCacheImageWithURL:(NSURL *)url
{
    if(!url) return nil;
    NSData *data = [NSData dataWithContentsOfFile:[self imagePathWithURL:url]];
    return [UIImage imageWithData:data];
}

+ (NSData *)getCacheImageDataWithURL:(NSURL *)url
{
    if(!url) return nil;
    return [NSData dataWithContentsOfFile:[self imagePathWithURL:url]];
}

//保存图片
+ (BOOL)saveImageData:(NSData *)data imageURL:(NSURL *)url
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self stLaunchAdCachePath], [self keyWithURL:url]];
    if (data) {
        BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        if (!result) STLaunchAdLog(@"cache file error for URL: %@",url);
        return result;
    }
    return NO;
}

//异步保存图片
+ (void)async_saveImageData:(NSData *)data
                   imageURL:(NSURL *)url
                  completed:(SaveCompletionBlock)completedBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self saveImageData:data imageURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completedBlock) {
                completedBlock(result, url);
            }
        });
    });
}

+ (BOOL)saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url
{
    NSString *savePath = [[self stLaunchAdCachePath] stringByAppendingString:[self videoNameWithURL:url]];
    NSURL *savePathUrl = [NSURL fileURLWithPath:savePath];
    BOOL result = [[NSFileManager defaultManager] moveItemAtURL:location toURL:savePathUrl error:nil];
    if (!result) STLaunchAdLog(@"cache file error for URL: %@",url);
    return result;
}

+ (void)async_saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url completed:(SaveCompletionBlock)completedBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self saveVideoAtLocation:location URL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completedBlock) {
                completedBlock(result, url);
            }
        });
    });
}

+ (NSURL *)getCacheVideoWithURL:(NSURL *)url
{
    NSString *savePath = [[self stLaunchAdCachePath] stringByAppendingString:[self videoNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        return [NSURL fileURLWithPath:savePath];
    }
    return nil;
}

+ (NSString *)stLaunchAdCachePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"Library/STLaunchAdCache"];
    [self checkDirectory:path];
    return path;
}

+ (NSString *)imagePathWithURL:(NSURL *)url
{
    if(!url) return nil;
    return [[self stLaunchAdCachePath] stringByAppendingPathComponent:[self keyWithURL:url]];
}

+ (NSString *)videoPathWithURL:(NSURL *)url
{
    if (!url) return nil;
    return [[self stLaunchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:url]];
}

+ (NSString *)videoPathWithFileName:(NSString *)videoFileName
{
    if(!videoFileName) return nil;
    return [[self stLaunchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:[NSURL URLWithString:videoFileName]]];
}

+ (BOOL)checkImageInCacheWithURL:(NSURL *)url
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self imagePathWithURL:url]];
}

+ (BOOL)checkVideoInChacheWithURL:(NSURL *)url
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPathWithURL:url]];
}

+ (BOOL)checkVideoInCacheWithFileName:(NSString *)videoFileName
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPathWithFileName:videoFileName]];
}

+ (void)checkDirectory: (NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self ]
    }
}

+ (NSString *)md5String:(NSString *)string
{
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++)
    {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

+ (NSString *)videoNameWithURL:(NSURL *)url
{
    return [[self md5String:url.absoluteString] stringByAppendingString:@".mp4"];
}

+ (NSString *)keyWithURL:(NSURL *)url
{
    return [self md5String:url.absoluteString];
}
@end
