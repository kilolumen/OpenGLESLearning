//
//  GLGeometry.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

typedef enum : NSUInteger
{
    GLGeometryTypeTriangles,
    GLGeometryTypeTriangleStrip,
    GLGeometryTypeTriangleFan
}GLGeometryType;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;//顶点坐标
    GLfloat normalX;
    GLfloat normalY;
    GLfloat normalZ;//法线坐标
    GLfloat u;
    GLfloat v;//纹理坐标
} GLVertex;

static inline GLVertex GLVertexMake(GLfloat x, GLfloat y, GLfloat z,
                                    GLfloat normalX, GLfloat normalY, GLfloat normalZ,
                                    GLfloat u, GLfloat v)
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
- (id)initWithGeometryType:(GLGeometryType)geomertryType;
- (void)appendVertex:(GLVertex)vertex;
- (GLuint)getVBO;
- (int)vertexCount;
@end
