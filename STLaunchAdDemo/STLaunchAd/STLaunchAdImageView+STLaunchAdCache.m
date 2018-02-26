//
//  STLaunchAdImageView+STLaunchAdCache.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdImageView+STLaunchAdCache.h"
#import "FLAnimatedImage.h"
#import "STLaunchAdConst.h"

@implementation STLaunchAdImageView (STLaunchAdCache)
- (void)st_setImageWithURL:(NSURL *)url
{
    [self st_setImageWithURL:url placeholderImage:nil];
}

- (void)st_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self st_setImageWithURL:url placeholderImage:placeholder options:STLaunchAdImageDefault];
}

- (void)st_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(STLaunchAdImageOptions)options
{
    [self st_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)st_setImageWithURL:(NSURL *)url completed:(STExternalCompletionBlock)completedBlock
{
    [self st_setImageWithURL:url placeholderImage:nil completed:completedBlock];
}

- (void)st_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(nullable STExternalCompletionBlock)completedBlock
{
    [self st_setImageWithURL:url placeholderImage:placeholder completed:completedBlock];
}

- (void)st_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(STLaunchAdImageOptions)options completed:(nullable STExternalCompletionBlock)completedBlock
{
    [self st_setImageWithURL:url placeholderImage:placeholder GIFImageCycleOnce:NO options:options GIFImageCycleOnceFinish:nil completed:completedBlock];
}

- (void)st_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder GIFImageCycleOnce:(BOOL)GIFImageCycleOnce options:(STLaunchAdImageOptions)options GIFImageCycleOnceFinish:(void (^)(void))cycleOnceFinishBlock completed:(STExternalCompletionBlock)completedBlock
{
    if (placeholder) {
        self.image = placeholder;
    }
    if (!url) {
        return;
    }
    STWeakSelf
    [[STLaunchAdImageManager shareManager] loadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, NSURL *imageURL) {
        if (!error) {
            if (STISGIFTypeWithData(imageData)) {
                weakSelf.image = nil;
                weakSelf.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                weakSelf.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if (GIFImageCycleOnce) {
                        [weakSelf stopAnimating];
                        STLaunchAdLog(@"GIF不循环，播放完成");
                        if (cycleOnceFinishBlock) {
                            cycleOnceFinishBlock();
                        }
                    }
                };
            }else{
                weakSelf.image = image;
                weakSelf.animatedImage = nil;
            }
        }
        if (completedBlock) {
            completedBlock(image, imageData, error, imageURL);
        }
    }];
}

@end
