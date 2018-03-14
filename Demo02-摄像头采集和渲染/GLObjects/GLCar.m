//
//  GLCar.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/14.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLCar.h"

@implementation GLCar
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath
{
    self = [super initWithGLContext:context objFile:filePath];
    
    if (!self) {
        
        return nil;
    }
    return self;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glcontext
{
    [glcontext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glcontext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    NSInteger vertexCount = self.positionIndexData.length / sizeof(GLuint);
    [self.context drawTrianglesWithVAO:vao vertexCount:(GLuint)vertexCount];
}
@end
