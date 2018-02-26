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
        [self createBaseDirectoryAtPath:path];
    }else{
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

#pragma mark - url缓存
+ (void)async_saveImageURL:(NSURL *)url
{
    if (nil == url) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:STCacheImageUrlStringKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (NSString *)getCacheImageUrl{
    return [[NSUserDefaults standardUserDefaults] objectForKey:STCacheImageUrlStringKey];
}

+ (NSString *)getCacheVideoUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:STCacheVideoUrlStringkey];
}

+ (void)async_saveVideoUrl:(NSString *)url
{
    if (nil == url) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:STCacheVideoUrlStringkey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

#pragma mark - other
+ (void)clearDiskCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [self stLaunchAdCachePath];
        [fileManager removeItemAtPath:path error:nil];
        [self checkDirectory:[self stLaunchAdCachePath]];
    });
}

+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray
{
    if(0 == imageUrlArray.count) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [imageUrlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self checkImageInCacheWithURL:obj]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self imagePathWithURL:obj] error:nil];
            }
        }];
    });
}

+ (void)clearDiskCacheWithExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allFilePaths = [self allFilePathWithDirectoryPath:[self stLaunchAdCachePath]];
        NSArray *exceptImagePaths = [self filePathsWithFileUrlArray:exceptImageUrlArray videoType:NO];
        [allFilePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![exceptImagePaths containsObject:obj] && !STISVideoTypeWithPath(obj)) {
                [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
            }
        }];
        STLaunchAdLog(@"allFilePath = %@", allFilePaths);
    });
}

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoArray
{
    if (0 == videoArray.count) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [videoArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self checkVideoInChacheWithURL:obj]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self videoPathWithURL:obj] error:nil];
            }
        }];
    });
}

+ (void)clearDiskCacheWithExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allFilePaths = [self allFilePathWithDirectoryPath:[self stLaunchAdCachePath]];
        NSArray *exceptVideoPaths = [self filePathsWithFileUrlArray:exceptVideoArray videoType:YES];
        [allFilePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![exceptVideoPaths containsObject:obj] && STISVideoTypeWithPath(obj)) {
                [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
            }
        }];
        STLaunchAdLog(@"allFilePath = %@", allFilePaths);
    });
}

+ (float)diskCacheSize
{
    NSString *directoryPath = [self stLaunchAdCachePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            if (nil == error) {
                for(NSString *subpath in array){
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedLongLongValue];
                    }
                }
            }
        }
    }
    return total / (1024.0 * 1024.0);
}

+ (NSArray *)allFilePathWithDirectoryPath:(NSString *)directoryPath
{
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for(NSString *fileName in tempArray){
        BOOL flag = YES;
        NSString *fullPath = [directoryPath stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                [array addObject:fullPath];
            }
        }
    }
    return array;
}

+ (NSArray *)filePathsWithFileUrlArray:(NSArray <NSURL *>*)fileUrlArray videoType:(BOOL)videoType
{
    NSMutableArray *filePaths = [NSMutableArray array];
    [fileUrlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path;
        if (videoType) {
            path = [self videoPathWithURL:obj];
        }else{
            path = [self imagePathWithURL:obj];
        }
        [filePaths addObject:path];
    }];
    return filePaths;
}

+ (void)createBaseDirectoryAtPath:(NSString *)path
{
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        STLaunchAdLog(@"create cache directory failed, error = %@",error);
    }else{
        [self addDoNotBackupAttribute:path];
    }
    STLaunchAdLog(@"STLaunchAdCachePath = %@",path);
}

+ (void)addDoNotBackupAttribute:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    //不希望Document下的文件被iCloud备份
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        STLaunchAdLog(@"error to set do not backup attribute, error = %@", error);
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
