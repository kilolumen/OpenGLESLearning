//
//  SRTPerformanceHelper.h
//  shiritan
//
//  性能问题排查、优化的便利方法集合类
//  Created by Yangtsing.Zhang on 2017/12/11.
//  Copyright © 2017年 Seamus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>

@interface SRTPerformanceHelper : NSObject

+ (double)machTimeToSeconds:(uint64_t)time;

@end
