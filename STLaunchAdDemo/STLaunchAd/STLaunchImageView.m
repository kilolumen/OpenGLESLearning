//
//  STLaunchImageView.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchImageView.h"
#import "STLaunchAdConst.h"

@interface STLaunchImageView ()

@end

@implementation STLaunchImageView

- (instancetype)initWithSourceType:(SourceType)sourceType
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        switch (sourceType) {
            case SourceTypeLaunchImage:
                self.image = [self imageFromLaunchImage];
                break;
            case SourceTypeLaunchScreen:
                self.image = [self imageFromLaunchScreen];
                break;
            default:
                break;
        }
    }
    return self;
}

- (UIImage *)imageFromLaunchImage
{
    UIImage *imageP = [self launchImageWithType:@"Portrait"];
    if (imageP) {
        return imageP;
    }
    UIImage *imageL = [self launchImageWithType:@"Landscape"];
    if (imageL) {
        return imageL;
    }
    STLaunchAdLog(@"获取LaunchImage失败！请检查是否添加启动图，或者规格是否有误。");
    return nil;
}

- (UIImage *)imageFromLaunchScreen
{
    NSString *UILaunchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    if (nil == UILaunchStoryboardName) {
        STLaunchAdLog(@"从LaunchScreen 中获取启动图失败");
        return nil;
    }
    UIViewController *LaunchScreenSb = [[UIStoryboard storyboardWithName:UILaunchStoryboardName bundle:nil] instantiateInitialViewController];
    if (LaunchScreenSb) {
        UIView *view = LaunchScreenSb.view;
        view.frame = [UIScreen mainScreen].bounds;
        UIImage *image = [self imageFromView:view];
        return image;
    }
    STLaunchAdLog(@"从 LaunchScreen 中获取启动图失败！");
    return nil;
}

- (UIImage *)imageFromView:(UIView *)view
{
    CGSize size = view.bounds.size;
    //参数1:表示区域的大小 参数2：如果需要显示半透镜效果，需要传NO，否则传YES 参数3:屏幕密度
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    return image;
}

- (UIImage *)launchImageWithType:(NSString *)type
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = type;
    NSString *launchImageName = nil;
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if ([viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            if ([dict[@"UILaunchImageOrientation"] isEqualToString:@"landscape"]) {
                imageSize = CGSizeMake(imageSize.height, imageSize.width);
            }
            if (CGSizeEqualToSize(imageSize, viewSize)) {
                launchImageName = dict[@"UILaunchImageName"];
                UIImage *image = [UIImage imageNamed:launchImageName];
                return image;
            }
        }
    }
    return nil;
}

@end
