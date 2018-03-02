//
//  WISenseTimeFaceConst.h
//  WeiboCamera
//
//  Created by ycpeng on 2017/10/31.
//  Copyright © 2017年 weibo. All rights reserved.
//

#ifndef WISenseTimeFaceConst_h
#define WISenseTimeFaceConst_h

/**
 * @brief FaceActionDetectionType，配置需要检测的脸部动作
 */
typedef NS_OPTIONS(unsigned long long, WIActionDetectOption) {
    WIActionDetectOptionNone              = 0,          //无
    WIActionDetectOptionFace              = 1 << 0,    //脸部
    WIActionDetectOptionEyeBlink          = 1 << 1,    //眨眼
    WIActionDetectOptionMouthOpen         = 1 << 2,    //张嘴
    WIActionDetectOptionHeadShake         = 1 << 3,    //摇头
    WIActionDetectOptionHeadNod           = 1 << 4,    //点头
    WIActionDetectOptionEyebrowQuirk      = 1 << 5,    //挑眉
    WIActionDetectOptionFaceAll           = 63,        //脸部所有
};

#endif /* WISenseTimeFaceConst_h */
