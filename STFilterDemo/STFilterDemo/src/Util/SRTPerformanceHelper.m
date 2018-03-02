//
//  SRTPerformanceHelper.m
//  shiritan
//
//  Created by Yangtsing.Zhang on 2017/12/11.
//  Copyright © 2017年 Seamus. All rights reserved.
//

#import "SRTPerformanceHelper.h"

@implementation SRTPerformanceHelper

///cpu tickcount 转换成时间的函数
+ (double)machTimeToSeconds:(uint64_t)time{
    mach_timebase_info_data_t timebase;
    
    mach_timebase_info(&timebase);
    
    return (double)time * (double)timebase.numer /
    (double)timebase.denom /1e9;
}

@end
