//
//  STLaunchAdImageView+STLaunchAdCache.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdView.h"
#import "STLaunchAdImageManager.h"

@interface STLaunchAdImageView (STLaunchAdCache)
- (void)st_setImageWithURL:(nonnull NSURL *)url;
- (void)st_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder;
- (void)st_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(STLaunchAdImageOptions)options;
- (void)st_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable STExternalCompletionBlock)completedBlock;
- (void)st_setImageWithURL:(nonnull NSURL *)url completed:(nullable STExternalCompletionBlock)completedBlock;
- (void)st_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(STLaunchAdImageOptions)options completed:(nullable STExternalCompletionBlock)completedBlock;
- (void)st_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder GIFImageCycleOnce:(BOOL)GIFImageCycleOnce options:(STLaunchAdImageOptions)options GIFImageCycleOnceFinish:(void(^_Nullable)(void))cycleOnceFinishBlock completed:(nullable STExternalCompletionBlock)completedBlock;
@end
