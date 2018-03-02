//
//  GPUImageFramebuffer+Depth.h
//  Pods
//
//  Created by ycpeng on 2017/9/8.
//  Copyright © 2017年 ycpeng. All rights reserved.
//

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#else
#import "GPUImage.h"
#endif

@interface GPUImageFramebuffer (Depth)

+ (void)hook;

@end
