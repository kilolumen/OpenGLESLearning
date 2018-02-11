//
//  Cube.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/8.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "Cube.h"
@interface Cube()
{
    GLuint vbo; //vertex buffer Object  顶点缓存
    GLuint vao; //vertex array object   顶点数组
}

@property (nonatomic, strong) GLKTextureInfo *normalMap;
@property (nonatomic, strong) GLKTextureInfo *diffuseMap;
@end

@implementation Cube
- (id)initWithGLContext:(GLContext *)context
             diffuseMap:(GLKTextureInfo *)diffuseMap
              normalMap:(GLKTextureInfo *)normalMap
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;//这里初始化了模型矩阵，模型矩阵的作用就是将GLObject放在世界坐标系中
        [self genVBO];
        [self genVAO];
        self.diffuseMap = diffuseMap;
        self.normalMap = normalMap;
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vao);
}

- (GLfloat *)cubeData
{
    static GLfloat cubeData[] = {
        // X轴0.5处的平面
        0.5f,   -0.5f,   0.5f, 1,  0,  0, 0, 0,
        0.5f,   -0.5f,  -0.5f, 1,  0,  0, 0, 1,
        0.5f,   0.5f,   -0.5f, 1,  0,  0, 1, 1,
        0.5f,   0.5f,   -0.5f, 1,  0,  0, 1, 1,
        0.5f,   0.5f,    0.5f, 1,  0,  0, 1, 0,
        0.5f,   -0.5f,   0.5f, 1,  0,  0, 0, 0,
        // X轴-0.5处的平面
        -0.5f,  0.5f,   -0.5f, -1,  0,  0, 1, 1,
        -0.5f,  -0.5f,  -0.5f, -1,  0,  0, 0, 1,
        -0.5f,  -0.5f,   0.5f, -1,  0,  0, 0, 0,
        -0.5f,  -0.5f,   0.5f, -1,  0,  0, 0, 0,
        -0.5f,  0.5f,    0.5f, -1,  0,  0, 1, 0,
        -0.5f,  0.5f,   -0.5f, -1,  0,  0, 1, 1,
        
        //Y轴0.5处的平面
        0.5f,   0.5f,   -0.5f, 0,  1,  0, 1, 1,
        -0.5f,  0.5f,   -0.5f, 0,  1,  0, 0, 1,
        -0.5f,  0.5f,   0.5f, 0,  1,  0, 0, 0,
        -0.5f,  0.5f,   0.5f, 0,  1,  0, 0, 0,
        0.5f,   0.5f,   0.5f, 0,  1,  0, 1, 0,
        0.5f,   0.5f,   -0.5f, 0,  1,  0, 1, 1,
        
        //Y轴-0.5处的平面
        -0.5f,  -0.5f,  0.5f, 0,  -1,  0, 0, 0,
        -0.5f,  -0.5f,  -0.5f, 0,  -1,  0, 0, 1,
        0.5f,   -0.5f,  -0.5f, 0,  -1,  0, 1, 1,
        0.5f,   -0.5f,  -0.5f, 0,  -1,  0, 1, 1,
        0.5f,   -0.5f,  0.5f, 0,  -1,  0, 1, 0,
        -0.5f,  -0.5f,  0.5f, 0,  -1,  0, 0, 0,
        
        //z轴0.5处的平面
        -0.5f,   0.5f,  0.5f,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.5f,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.5f,  0,  0,  1, 1, 1,
        0.5f,   -0.5f,  0.5f,   0,  0,  1, 1, 1,
        0.5f,   0.5f,   0.5f,    0,  0,  1, 1, 0,
        -0.5f,  0.5f,   0.5f,  0,  0,  1, 0, 0,
        
        //z轴-0.5出的平面
        0.5f,   -0.5f,  -0.5f,  0,  0,  -1, 1, 1,
        -0.5f,  -0.5f,  -0.5f,  0,  0,  -1, 0, 1,
        -0.5f,  0.5f,   -0.5f,   0,  0,  -1, 0, 0,
        -0.5f,  0.5f,   -0.5f,  0,  0,  -1, 0, 0,
        0.5f,   0.5f,   -0.5f,    0,  0,  -1, 1, 0,
        0.5f,   -0.5f,  -0.5f,   0,  0,  -1, 1, 1,
    };
    
    return cubeData;
}

- (void)genVBO
{
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 36 * 8 * sizeof(GLfloat), [self cubeData], GL_STATIC_DRAW);
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
{
    
}

- (void)draw:(GLContext *)glcontext
{
    [glcontext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glcontext setUniformMatrix4fv:@"normal" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glcontext bindTexture:self.diffuseMap to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glcontext bindTexture:self.normalMap to:GL_TEXTURE1 uniformName:@"normalMap"];
    [glcontext drawTrianglesWithVAO:vao vertexCount:36];
}
@end
