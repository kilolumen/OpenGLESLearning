//
//  GLContext.h
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/22.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@class GLGeometry;
@interface GLContext : NSObject
@property (nonatomic, assign) GLuint program;
+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath
               fragmentShaderPath:(NSString *)fragmentShaderPath;
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;
- (void)active;
- (void)bindAttributes:(GLfloat *)triangleData;

//draw functions
- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVBO:(GLuint)vbo vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVAO:(GLuint)vao vertexCount:(GLint)vertexCount;


//uniform setters
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value;
- (void)setUniform1f:(NSString *)uniformName value:(GLint)value;
- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value;
- (void)setUniform4fv:(NSString *)uniformName value:(GLKVector4)value;
- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value;

- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
- (void)bindTextureName:(GLuint)textureName to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
@end
