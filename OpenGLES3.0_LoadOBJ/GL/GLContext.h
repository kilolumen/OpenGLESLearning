//
//  GLContext.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@class GLGeometry;
@interface GLContext : NSObject
@property (nonatomic, assign) GLuint program;
+ (id)contextWithVertexShaderPath:(NSString *)vertessShaderPath
               fragmentShaderPath:(NSString *)gragmentShaderPath;
- (id)initWithVertexShader:(NSString *)vertexShader
            fragmentShader:(NSString *)fragmentShader;
- (void)active;
- (void)bindAttribs:(GLfloat *)triangleData;


//draw function
- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVBO:(GLuint)vbo vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVAO:(GLuint)vao vertexCount:(GLint)vertexCount;
- (void)drawGeometry:(GLGeometry *)geometry;

/// uniform setters
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value;
- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value;
- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value;
- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value;

/// texture
- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
@end
