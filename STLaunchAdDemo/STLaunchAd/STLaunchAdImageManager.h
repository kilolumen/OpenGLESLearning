//
//  STLaunchAdImageManager.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STLaunchAdDownloader.h"

typedef NS_OPTIONS(NSUInteger, STLaunchAdImageOptions) {
    STLaunchAdImageDefault = 1 << 0,
    STLaunchAdImageOnlyLoad = 1 << 1,
    STLaunchAdImageRefreshCached = 1 << 2,
    STLaunchAdImageCacheInBackground = 1 << 3
};

typedef void(^STExternalCompletionBlock) (UIImage *image, NSData *imageData, NSError *error, NSURL *imageURL);

@interface STLaunchAdImageManager : NSObject

+ (nonnull instancetype)shareManager;

- (void)loadImageWithURL:(nullable NSURL *)url options:(STLaunchAdImageOptions)options progress:(nullable STLaunchAdDownloadProgressBlock)progresBlock completed:(nullable STExternalCompletionBlock)completedBlock;
@end
