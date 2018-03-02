//
//  CommonDefine.h
//  STFilterDemo
//
//  Created by Yangtsing.Zhang on 2018/1/30.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h

#import "CHLog.h"

/*
 * 全局函数定义宏
 */
#if defined (__cplusplus)
#define SRT_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define SRT_EXTERN extern __attribute__((visibility("default")))
#endif


#endif /* CommonDefine_h */
