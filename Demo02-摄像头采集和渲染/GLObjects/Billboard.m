//
//  Billboard.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/4/2.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "Billboard.h"

@interface Billboard ()
{
    GLuint vbo;
    GLuint vao;
    GLKTextureInfo *diffuseTexture;
}
@end

@implementation Billboard
- (instancetype)initWithGLContext:(GLContext *)context texture:(GLKTextureInfo *)texture
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        diffuseTexture = texture;
        [self genVBO];
        [self genVAO];
    }
    return self;
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vao);
}

- (GLfloat *)planeData
{
    static GLfloat planeData[] = {
        -0.5,   0.5f,  0.0,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.0,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.0,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.0,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.0,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.0,  0,  0,  1, 0, 0,
    };
    return planeData;
}

- (void)genVBO
{
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 36 * 8 * sizeof(GLfloat), [self planeData], GL_STATIC_DRAW);
}

- (void)genVAO
{
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    [self.context bindGeometryAttribs:NULL];
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glcontext
{
    [glcontext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    [glcontext setUniform2fv:@"billboardSize" value:self.billboardSize];
    [glcontext setUniform3fv:@"billboardCenterPosition" value:self.billboardCenterPosition];
    [glcontext setUniform1i:@"lockToYAxis" value:self.lockToYAxis];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glcontext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glcontext bindtexture:diffuseTexture.name to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glcontext drawTrianglesWithVAO:vao vertexCount:6];
}
@end
