//
//  GLGeometry.m
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLGeometry.h"

@interface GLGeometry (){
    GLuint vbo;
    BOOL vboValid;
}
@property (nonatomic, strong) NSMutableData *vertexData;
@end

@implementation GLGeometry

- (instancetype)initWithGeometryType:(GLGeometryType)geometryType
{
    self = [super init];
    
    if (self) {
        
        self.geometryType = geometryType;
        vboValid = NO;
        self.vertexData = [NSMutableData data];
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
    [self.vertexData appendBytes:pVertex length:size];
}

- (GLuint)getVBO
{
    if (vboValid == NO) {
        glGenBuffers(1, &vbo);
        vboValid = YES;
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, [self.vertexData length], self.vertexData.bytes, GL_STATIC_DRAW);
    }
    
    return vbo;
}

- (int)vertexCount
{
    return [self.vertexData length] / sizeof(GLVertex);
}
@end
