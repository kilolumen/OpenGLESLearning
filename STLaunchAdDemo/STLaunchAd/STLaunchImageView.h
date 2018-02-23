//
//  STLaunchImageView.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SourceType) {
    SourceTypeLaunchImage = 1,
    SourceTypeLaunchScreen = 2,
};

typedef NS_ENUM(NSInteger, LaunchImagesSource) {
    LaunchImagesSourceLaunchImage = 1,
    LaunchImagesSourceLaunchScreen = 2,
};

@interface STLaunchImageView : UIImageView

- (instancetype)initWithSourceType:(SourceType)sourceType;

@end
