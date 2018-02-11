//
//  Camera.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/4.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject
@property (nonatomic, assign) GLKVector3 forward;//摄像机方向
@property (nonatomic, assign) GLKVector3 up;//摄像机正方向
@property (nonatomic, assign) GLKVector3 position;//摄像头位置
- (void)setupCameraWithEye:(GLKVector3)eye
                    lookAt:(GLKVector3)lookAt
                        up:(GLKVector3)up;
- (void)mirrorTo:(Camera *)targetCamera
           plane:(GLKVector4)plane;
- (GLKMatrix4)cameraMaxtrx;
@end
