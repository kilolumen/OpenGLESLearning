//
//  ARKitOpenGLRenderController.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/5/9.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GLBaseViewController.h"
#import <ARKit/ARKit.h>
@import ARKit;

@interface ARKitOpenGLRenderController : GLBaseViewController<ARSessionDelegate>
@property (nonatomic, strong) ARSession  *arSession;
@property (nonatomic, assign) GLKMatrix4 worldProjectionMatrix;
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@end
