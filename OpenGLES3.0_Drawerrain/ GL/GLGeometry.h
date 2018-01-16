//
//  GLGeometry.h
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

typedef enum : NSUInteger{
    GLGeometryTypeTriangles,
    GLGeometryTypeTriangleStrip,
    GLGeometryTypeTriangleFan
}GLGeometryType;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat normalX;
    GLfloat normalY;
    GLfloat normalZ;
    GLfloat u;
    GLfloat v;
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
};

@interface GLGeometry : GLObject
@property (nonatomic, assign) GLGeometryType geometryType;
- (instancetype)initWithGeometryType:(GLGeometryType)geometryType;
- (void)appendVertex:(GLVertex)vertex;
- (GLuint)getVBO;
- (int)vertexCount;
@end
