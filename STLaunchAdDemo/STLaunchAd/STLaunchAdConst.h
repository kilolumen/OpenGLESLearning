//
//  STLaunchAdConst.h
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STLaunchAdDeprecated(instead) __attribute__((deprecated(instead))

#define STWeakSelf __weak typeof(self) weakSelf = self;

#define ST_ScreenW [UIScreen mainScreen].bounds.size.width
#define ST_ScreenH [UIScreen mainScreen].bounds.size.height

#define ST_IPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define STISURLString(string) ([string hasPrefix:@"https://"] || [string hasPrefix:@"http://"]) ? YES : NO
#define STStringContainsSubString(string, subString) ([string rangeOfString:subString].location == NSNotFound) ? NO : YES

#ifdef DEBUG
#define STLaunchAdLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define STLaunchAdLog(...)
#endif

#define STISGIFTypeWithData(data)\
({\
BOOL result = NO;\
if(!data) result = NO;\
uint8_t c;\
[data getBytes:&c length:1];\
if(c == 0x47) result = YES;\
(result);\
})

#define STISVideoTypeWithPath(path)\
({\
BOOL result = NO;\
if([path hasSuffix:@".mp4"]) result = YES;\
(result);\
})

#define STDataWithFileName(name)\
({\
NSData *data = nil;\
NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];\
if([[NSFileManager defaultManager] fileExistsAtPath:path]){\
    data = [NSData dataWithContentsOfFile:path];\
}\
(data);\
})

#define DISPATCH_SOURCE_CANCEL_SAFE(time) if(time)\
{\
dispatch_source_cancel(time);\
time = nil;\
}

#define REMOVE_FROM_SUPERVIEW_SAFE(view) if(view)\
{\
[view removeFromSuperview];\
view = nil;\
}

UIKIT_EXTERN NSString *const STCacheImageUrlStringKey;
UIKIT_EXTERN NSString *const STCacheVideoUrlStringkey;

UIKIT_EXTERN NSString *const STLaunchAdWaitDataDurationArriveNotification;
UIKIT_EXTERN NSString *const STLaunchAdDetailPageWillShowNotification;
UIKIT_EXTERN NSString *const STLaunchAdDetailPageShowFinishNotification;
UIKIT_EXTERN NSString *const STLaunchAdGIFImageCycleOnceFinishNotification;
UIKIT_EXTERN NSString *const STLaunchAdVideoCyclyOnceFinishNotification;
UIKIT_EXTERN NSString *const STLaunchAdVideoPlayFailedNotification;
UIKIT_EXTERN BOOL STLaunchAdPrefersHomeIndicatorAutoHidden;
