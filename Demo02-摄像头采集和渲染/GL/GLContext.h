//
//  GLContext.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@class GLGeometry;
@interface GLContext : NSObject
@property (nonatomic, assign) GLuint program;
+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath;
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;
- (void)active;
- (void)bindAttribs:(GLfloat *)trangleData;

//draw function
- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLuint)vertexCount;
- (void)drawTrianglesWithVBO:(GLuint)vbo vertexCount:(GLuint)vertexCount;
- (void)drawTrianglesWithVAO:(GLuint)vao vertexCount:(GLuint)vertexCount;
- (void)drawGeometry:(GLGeometry *)geometry;

//uniform setters
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value;
- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value;
- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value;
- (void)setUniformMatrix3fv:(NSString *)uniformName value:(GLfloat *)value;
- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value;

//texture
- (void)bindTexture:(GLKTextureInfo *)textureInto to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
- (void)bindtexture:(GLuint)texture to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
- (void)bindCubeTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
@end
