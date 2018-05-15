//
//  VideoPlane.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/5/9.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface VideoPlane : GLObject
@property (nonatomic, assign) GLuint yuv_yTexture;
@property (nonatomic, assign) GLuint yuv_uvTexture;
- (instancetype)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
