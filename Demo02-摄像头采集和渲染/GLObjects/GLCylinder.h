//
//  GLCylinder.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/9.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface GLCylinder : GLObject
@property (assign, nonatomic) int sideCount;
@property (assign, nonatomic) GLfloat radius;
@property (assign, nonatomic) GLfloat height;

- (instancetype)initWithGLContext:(GLContext *)context sides:(int)sides radius:(GLfloat)radius height:(GLfloat)height texture:(GLKTextureInfo *)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
