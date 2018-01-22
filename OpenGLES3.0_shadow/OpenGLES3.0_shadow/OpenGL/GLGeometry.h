//
//  GLGeometry.h
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/22.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

typedef enum : NSUInteger
{
    GLGeometryTypeTriangles,//三角形
    GLGeometryTypeTriangleStrip,//三角带
    GLGeometryTypeTriangleFan,//扇形
}GLGeometryType;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;//positon
    GLfloat normalX;
    GLfloat normalY;
    GLfloat normalZ;//normal
    GLfloat u;
    GLfloat v;//textureCoord
}GLVertex;

static inline GLVertex GLVertexMake(GLfloat x,
                                    GLfloat y,
                                    GLfloat z,
                                    GLfloat normalX,
                                    GLfloat normalY,
                                    GLfloat normalZ,
                                    GLfloat u,
                                    GLfloat v)
{
    GLVertex vertex;
    vertex.x = x;
    vertex.y = y;
    vertex.z = z;
    vertex.normalX = normalX;
    vertex.normalY = normalY;
    vertex.normalZ = normalZ;
    vertex.u = u;
    vertex.v = v;
    return vertex;
}

@interface GLGeometry : GLObject

@property (nonatomic, assign) GLGeometryType geometryType;

- (instancetype)initWithGeometryType:(GLGeometryType)geometryType;
- (void)appendVertex:(GLVertex)vertex;
- (GLuint)getVBO;
- (int)vertexCount;
@end
