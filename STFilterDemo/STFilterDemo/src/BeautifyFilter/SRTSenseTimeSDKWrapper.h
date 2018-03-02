//
//  SRTSenseTimeSDKWrapper.h
//  shiritan
//
//  Created by Yangtsing.Zhang on 2018/1/23.
//  Copyright © 2018年 Seamus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "st_mobile_human_action.h"
#import <OpenGLES/EAGL.h>
#import "GPUImage.h"
#import "CommonDefine.h"


#define SRTSenseTimeSDKWrapper_Instance [SRTSenseTimeSDKWrapper mainConsole]

typedef NS_ENUM(NSUInteger, ST_INPUT_TYPE) {
    ST_INPUT_TYPE_INVALID = -1,
    ST_INPUT_TYPE_IMAGE = 0,
    ST_INPUT_TYPE_VIDEO = 1,
};

@interface SRTSenseTimeSDKWrapper : NSObject

///商汤sdk做OpenGL操作的上下文
@property (nonatomic, strong) EAGLContext *stGLContext;

@property (nonatomic, readonly) ST_INPUT_TYPE inputType;

///美肌肤 - [0 , 1]
@property (nonatomic, assign) float skinBeautyStrength;

///美颜(形体) - [0 , 1]
@property (nonatomic, assign) float shapeBeautyStrength;

@property (nonatomic, assign) st_mobile_human_action_t faceDetectRet;

- (st_handle_t)faceDetectHandle;


///单例获取
+ (SRTSenseTimeSDKWrapper *)mainConsole;

///根据输入源类型创建人脸检测，美颜句柄，需要外部手动调用
- (void)createHandlesOfType:(ST_INPUT_TYPE)type;

///释放sdk句柄(人脸检测&美颜)
- (void)releaseHandles;

///将sdk句柄处理的输入源类型切换到相应的类型, 如果该类型已经存在则无操作
- (void)switchHandlesToType:(ST_INPUT_TYPE)type;

///切换到商汤sdk OpenGL上下文
- (void)useSensetimeGLContext;

///人脸检测
- (void)detectFaceInImage:(const unsigned char *)p_image width:(int)imgWidth height:(int)imgHeight bytesPerRow:(int)byteNumPerRow rotation:(GPUImageRotationMode)rotation detectRet:(st_mobile_human_action_t *)detectRet;

///美颜
- (void)beautifyTexture:(GLuint)originTexture retTexture:(GLuint)retTexture width:(int)width height:(int)height faceDetectRet:(st_mobile_human_action_t *)p_faceDetectRet;

@end
