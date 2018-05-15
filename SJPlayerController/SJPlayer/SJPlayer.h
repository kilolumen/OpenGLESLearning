//
//  SJPlayer.h
//  SJPlayerController
//
//  Created by sensetimesunjian on 2018/5/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPlayer : NSObject
- (id)initWithMoviePath:(NSString *)moviePath;
- (void)play;
- (void)pause;
@end
