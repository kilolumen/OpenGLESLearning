//
//  GLGeometry.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLGeometry.h"

@interface GLGeometry()
{
    GLuint vbo;
    BOOL vboValid;
}
@property (nonatomic, strong) NSMutableData *vertexData;
@end

@implementation GLGeometry
- (id)initWithGeometryType:(GLGeometryType)geomertryType
{
    self = [super init];
    
    if (self) {
        
        self.geometryType = geomertryType;
        
        vboValid = NO;
        
        self.vertexData = [NSMutableData data];
        
        return self;
    }
    
    return self;
}

- (void)dealloc
{
    if (vboValid) {
        glDeleteBuffers(1, &vbo);
    }
}

- (void)appendVertex:(GLVertex)vertex
{
    void *pVertex = (void *)(&vertex);
    NSUInteger size = sizeof(GLVertex);
    [self.vertexData appendBytes:pVertex length:size];//如何操作指针
}

- (GLuint)getVBO
{
    if (vboValid == NO) {
        glGenBuffers(1, &vbo);
        vboValid = YES;
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, self.vertexData.length, self.vertexData.bytes, GL_STATIC_DRAW);
    }
    return vbo;
}

- (int)vertexCount
{
    return (int)self.vertexData.length/sizeof(GLVertex);
}

@end
