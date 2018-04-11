//
//  GLSphere.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/4/11.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLSphere.h"
#import "OSShaderManager.h"
#import "OSSphere.h"
#import <GLKit/GLKit.h>

/**
 *  定义一下关于球体模型的常量
 */
#define OSMAX_OVERTURE 95.0
#define OSMIN_OVERTURE 25.0
#define OSDEFAULT_OVERTURE 85.0

#define OSROLL_CORRECTION ES_PI/2.0
#define OSFramesPerSecond 60  // 帧率
#define OSSphereSliceNum 300
#define OSSphereRadius 1.0   // 球体模型半径
#define OSSphereScale 300
#define OSVIEW_CORNER  85.0  // 视角

@interface GLSphere ()
{
    // 着色器变量标识
    GLuint _textureBuffer;
    GLuint _modelViewProjectionMatrixIndex;
    GLuint _texCoordIndex;
    
    // 顶点数据，纹理坐标数组
    GLfloat *_vertices  ;
    GLfloat *_texCoords  ;
    GLushort *_indices  ;
    GLint  _numIndices;
    
    // 顶点和纹理坐标属性标识
    GLuint _vertexBuffer;
    GLuint _textureCoordBuffer;
    GLuint _indexBuffer;
    
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLKMatrix4 _modelViewProjectionMatrix;
}
@property (nonatomic, strong) OSShaderManager *shaderManager;
@end

@implementation GLSphere

- (id)init
{
    self = [super init];
    if (self) {
        [self createProgram];
        [self loadVertexAndTexCoord];
        [self initModelViewProjectMatrix];
    }
    return self;
}

- (void)createProgram
{
    self.shaderManager = [[OSShaderManager alloc]init];
    // 编译连个shader 文件
    GLuint vertexShader,fragmentShader;
    NSURL *vertexShaderPath = [[NSBundle mainBundle]URLForResource:@"ShaderPanorama" withExtension:@"vsh"];
    NSURL *fragmentShaderPath = [[NSBundle mainBundle]URLForResource:@"ShaderPanorama" withExtension:@"fsh"];
    if (![self.shaderManager compileShader:&vertexShader type:GL_VERTEX_SHADER URL:vertexShaderPath]||![self.shaderManager compileShader:&fragmentShader type:GL_FRAGMENT_SHADER URL:fragmentShaderPath]){
        return ;
    }
    
    [self.shaderManager bindAttribLocation:GLKVertexAttribPosition andAttribName:"position"];
    [self.shaderManager bindAttribLocation:GLKVertexAttribTexCoord0 andAttribName:"texCoord0"];
    
    
    // 将编译好的两个对象和着色器程序进行连接
    if(![self.shaderManager linkProgram]){
        [self.shaderManager deleteShader:&vertexShader];
        [self.shaderManager deleteShader:&fragmentShader];
    }
    _textureBuffer = [self.shaderManager getUniformLocation:"sam2D"];
    _modelViewProjectionMatrixIndex = [self.shaderManager getUniformLocation:"modelViewProjectionMatrix"];
    
    [self.shaderManager detachAndDeleteShader:&vertexShader];
    [self.shaderManager detachAndDeleteShader:&fragmentShader];
    
    GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"park.jpg"].CGImage options:nil error:nil];
    
    _textureBuffer = texture.name;
    
    // 启用着色器
    [self.shaderManager useProgram];
    
    glUniform1i(_textureBuffer, 0);
    
}

-(void)loadVertexAndTexCoord{
    
    int numVertices = 0; // 顶点的个数
    int strideNum = 2; // 数据的步伐数 比如顶点数据为(1,1)，数组就为2
    
    
    _numIndices =  generateSphere(OSSphereSliceNum, OSSphereRadius, &_vertices, &_texCoords, &_indices, &numVertices);
        strideNum = 3;
    
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _numIndices*sizeof(GLushort), _indices, GL_STATIC_DRAW);
    
    
    // 加载顶点坐标
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, numVertices*strideNum*sizeof(GLfloat), _vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, strideNum, GL_FLOAT, GL_FALSE, strideNum*sizeof(GLfloat), NULL);
    
    //加载纹理坐标
    glGenBuffers(1, &_textureCoordBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _textureCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*2*numVertices, _texCoords, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), NULL);
    
    // 释放内存
    free(_vertices);
    free(_indices);
    free(_texCoords);
}

-(void)initModelViewProjectMatrix{
    
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(OSVIEW_CORNER), 9/16, 0.1f, 400.0f);
    _projectionMatrix = GLKMatrix4Rotate(_projectionMatrix, ES_PI, 1.0f, 0.0f, 0.0f);
    
    // 创建模型矩阵
    _modelViewMatrix = GLKMatrix4Identity;
    float scale = OSSphereScale;
    _modelViewMatrix = GLKMatrix4Scale(_modelViewMatrix, scale, scale, scale);
    
    // 最终传入到GLSL中去的矩阵
    _modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
    glUniformMatrix4fv(_modelViewProjectionMatrixIndex, 1, GL_FALSE, _modelViewProjectionMatrix.m);
}

- (void)draw
{
    glDrawElements(GL_TRIANGLES, _numIndices, GL_UNSIGNED_SHORT, 0);
}
@end
