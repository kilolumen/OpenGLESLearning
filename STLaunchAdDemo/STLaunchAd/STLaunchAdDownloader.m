//
//  STLaunchAdDownloader.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdDownloader.h"
#import "STLaunchAdCache.h"
#import "STLaunchAdConst.h"

@interface STLaunchAdDownload ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;
@property (nonatomic, copy)   STLaunchAdDownloadProgressBlock progressBlock;
@property (nonatomic, strong) NSURL *url;
@end

@implementation STLaunchAdDownload
@end

@interface STLaunchAdImageDownload()<NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, copy) STLaunchAdDownloadImageCompletedBlock completedBlock;
@end

@implementation STLaunchAdImageDownload
- (nonnull instancetype)initWithURL:(nonnull NSURL *)url
                      delegateQueue:(nonnull NSOperationQueue *)queue
                           progress:(nullable STLaunchAdDownloadProgressBlock)progressBlock
                          completed:(nullable STLaunchAdDownloadImageCompletedBlock)completedBlock
{
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        self.completedBlock = completedBlock;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15.0;//这是配置的session的超时时间
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:queue];
        self.downloadTask = [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_completedBlock) {
            _completedBlock(image, data, nil);
            _completedBlock = nil;
        }
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    if (error) {
        STLaunchAdLog(@"error = %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_completedBlock) {
                _completedBlock(nil, nil, error);
            }
            _completedBlock = nil;
        });
    }
}
//处理HTTPS请求的
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}
@end

@interface STLaunchAdVideoDownload()<NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, copy) STLaunchAdDownloadVideoCompletedBlock completedBlock;
@end

@implementation STLaunchAdVideoDownload

-(nonnull instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable STLaunchAdDownloadProgressBlock)progressBlock completed:(nullable STLaunchAdDownloadVideoCompletedBlock)completedBlock{
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        _completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        self.downloadTask =  [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSError *error=nil;
    NSURL *toURL = [NSURL fileURLWithPath:[STLaunchAdCache videoPathWithURL:self.url]];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&error];
    if(error)  STLaunchAdLog(@"error = %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_completedBlock) {
            if(!error){
                _completedBlock(toURL,nil);
            }else{
                _completedBlock(nil,error);
            }
            // 防止重复调用
            _completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error){
        STLaunchAdLog(@"error = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_completedBlock) {
                _completedBlock(nil, error);
            }
            _completedBlock = nil;
        });
    }
}
@end

@interface STLaunchAdDownloader ()<STLaunchAdDownladDelegate>
@property (nonatomic, strong, nonnull) NSOperationQueue *downloadImageQueue;
@property (nonatomic, strong, nonnull) NSOperationQueue *downloadVideoQueue;
@property (nonatomic, strong) NSMutableDictionary *allDownloadDict;
@end
@implementation STLaunchAdDownloader

+ (nonnull instancetype)sharedDownloader
{
    static STLaunchAdDownloader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STLaunchAdDownloader alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadImageQueue = [NSOperationQueue new];
        _downloadImageQueue.maxConcurrentOperationCount = 6;
        _downloadImageQueue.name = @"com.sensetime.downloadImageQueue";
        _downloadVideoQueue = [NSOperationQueue new];
        _downloadVideoQueue.maxConcurrentOperationCount = 3;
        _downloadVideoQueue.name = @"com.sensetime.downloadVideoQueue";
        STLaunchAdLog(@"STLaunchAdCachePath:%@", [STLaunchAdCache stLaunchAdCachePath]);
    }
    return self;
}

- (void)downloadImageWithURL:(NSURL *)url progress:(STLaunchAdDownloadProgressBlock)progressBlock completed:(STLaunchAdDownloadImageCompletedBlock)completedBlock
{
    NSString *key = [self keyWithURL:url];
    if (self.allDownloadDict[key]) {
        return;
    }
    STLaunchAdImageDownload *imageDownload = [[STLaunchAdImageDownload alloc] initWithURL:url delegateQueue:_downloadImageQueue progress:progressBlock completed:completedBlock];
    imageDownload.delegate = self;
    [self.allDownloadDict setObject:imageDownload forKey:key];
}

- (void)downloadImageAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock
{
    if (nil == url) {
        if (completedBlock) {
            completedBlock(NO);
        }
        return;
    }
    [self downloadImageWithURL:url progress:nil completed:^(UIImage *image, NSData *data, NSError *error) {
        if (error) {
            if (completedBlock) {
                completedBlock(NO);
            }
        }else{
            [STLaunchAdCache async_saveImageData:data imageURL:url completed:^(BOOL result, NSURL * _Nonnull URL) {
                if (completedBlock) {
                    completedBlock(result);
                }
            }];
        }
    }];
}

- (void)downloadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray
{ 
    [self downloadImageAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downloadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray completed:(nullable STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock
{
    if (0 == urlArray.count) {
        return;
    }
    __block NSMutableArray *resultArray = [NSMutableArray array];
    dispatch_group_t downloadGroup = dispatch_group_create();
    [urlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![STLaunchAdCache checkImageInCacheWithURL:obj]) {
            dispatch_group_enter(downloadGroup);
            [self downloadImageAndCacheWithURL:obj completed:^(BOOL result) {
                dispatch_group_leave(downloadGroup);
                [resultArray addObject:@{@"url":obj.absoluteString, @"result":@(result)}];
            }];
        }else{
            [resultArray addObject:@{@"url":obj .absoluteString,@"result":@(YES)}];
        }
    }];
    
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        if (completedBlock) {
            completedBlock(resultArray);
        }
    });
}

- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable STLaunchAdDownloadProgressBlock)progressBlock completed:(nullable STLaunchAdDownloadVideoCompletedBlock)completedBlock{
    NSString *key = [self keyWithURL:url];
    if(self.allDownloadDict[key]) return;
    STLaunchAdVideoDownload * download = [[STLaunchAdVideoDownload alloc] initWithURL:url delegateQueue:_downloadVideoQueue progress:progressBlock completed:completedBlock];
    download.delegate = self;
    [self.allDownloadDict setObject:download forKey:key];
}

- (void)downloadVideoAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock{
    if(url == nil){
        if(completedBlock) completedBlock(NO);
        return;
    }
    [self downloadVideoWithURL:url progress:nil completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
        if(error){
            if(completedBlock) completedBlock(NO);
        }else{
            [STLaunchAdCache async_saveVideoAtLocation:location URL:url completed:^(BOOL result, NSURL * _Nonnull URL) {
                if(completedBlock) completedBlock(result);
            }];
        }
    }];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable STLaunchAdBatchDownloadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    __block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    dispatch_group_t downLoadGroup = dispatch_group_create();
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        if(![STLaunchAdCache checkVideoInChacheWithURL:url]){
            dispatch_group_enter(downLoadGroup);
            [self downloadVideoAndCacheWithURL:url completed:^(BOOL result) {
                dispatch_group_leave(downLoadGroup);
                [resultArray addObject:@{@"url":url.absoluteString,@"result":@(result)}];
            }];
        }else{
            [resultArray addObject:@{@"url":url.absoluteString,@"result":@(YES)}];
        }
    }];
    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
        if(completedBlock) completedBlock(resultArray);
    });
}

- (NSMutableDictionary *)allDownloadDict
{
    if (!_allDownloadDict) {
        _allDownloadDict = [[NSMutableDictionary alloc] init];
    }
    return _allDownloadDict;
}

- (void)downloadFinishWithURL:(NSURL *)url
{
    [self.allDownloadDict removeObjectForKey:[self keyWithURL:url]];
}

-(NSString *)keyWithURL:(NSURL *)url{
    return [STLaunchAdCache md5String:url.absoluteString];
}
@end
