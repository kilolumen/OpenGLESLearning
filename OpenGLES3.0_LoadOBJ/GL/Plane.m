//
//  Plane.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/18.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "Plane.h"

@interface Plane()
{
    GLuint vbo;
    GLuint vao;
    GLuint diffuseTexture;
}
@end

@implementation Plane

- (instancetype)initWithGLContext:(GLContext *)context texture:(GLuint)texture
{
    self = [super initWithGLContext:context];
    
    if (self) {
        
        self.modelMatrix = GLKMatrix4Identity;
        diffuseTexture = texture;
        [self genVBO];
        [self genVAO];
        return self;
    }
    
    return nil;
}

- (void)dealloc
{
    glDeleteBuffers(1, &vao);
    glDeleteBuffers(1, &vbo);
}

- (GLfloat *)planeData
{
    static GLfloat planeData[] = {
        -0.5,   0.5f,  0.5,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.5,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.5,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.5,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.5,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.5,  0,  0,  1, 0, 0,
    };
    
    return planeData;
}

- (void)genVBO
{
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 6 * 8 * sizeof(GLfloat), [self planeData], GL_STATIC_DRAW);
}

- (void)genVAO
{
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    [self.context bindAttribs:NULL];
    
    glBindVertexArrayOES(0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{}

- (void)draw:(GLContext *)glcontext
{
    [glcontext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glcontext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glcontext bindTextureName:diffuseTexture to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glcontext drawTrianglesWithVAO:vao vertexCount:16];
}
@end
