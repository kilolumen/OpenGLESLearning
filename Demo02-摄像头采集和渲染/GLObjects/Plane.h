//
//  Plane.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface Plane : GLObject
- (instancetype)initWithGLContext:(GLContext *)context textureY:(GLuint)textureY textureUV:(GLuint)textureUV matrix:(GLfloat *)matrix3;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
