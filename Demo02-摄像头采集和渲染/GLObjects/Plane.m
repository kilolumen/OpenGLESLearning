//
//  Plane.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "Plane.h"

@interface Plane()
{
    GLuint _textureY;
    GLuint _textureUV;
    GLfloat *_matrix3;
}
@end

@implementation Plane
- (instancetype)initWithGLContext:(GLContext *)context textureY:(GLuint)textureY textureUV:(GLuint)textureUV matrix:(GLfloat *)matrix3
{
    self = [super initWithGLContext:context];
    
    if (self) {
        _textureY = textureY;
        _textureUV = textureUV;
        _matrix3 = matrix3;
        return  self;
    }
    
    return self;
}

- (GLfloat *)planeData
{
    static GLfloat plandeData[] = {
        -1.0,  1.0, 0.0, 1.0,
        -1.0, -1.0, 0.0, 0.0,
         1.0, -1.0, 1.0, 0.0,
         1.0, -1.0, 1.0, 0.0,
         1.0,  1.0, 1.0, 1.0,
        -1.0,  1.0, 0.0, 1.0,
    };
    return plandeData;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glcontext
{
    [glcontext bindtexture:_textureY to:GL_TEXTURE0 uniformName:@"SamplerY"];
    [glcontext bindtexture:_textureUV to:GL_TEXTURE1 uniformName:@"SamplerUV"];
    [glcontext setUniformMatrix3fv:@"colorConversionMatrix" value:_matrix3];
    [glcontext drawTriangles:[self planeData] vertexCount:6];
}
@end
