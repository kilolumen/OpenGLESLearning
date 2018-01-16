//
//  GLContext.m
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLContext.h"
#import "GLGeometry.h"

@implementation GLContext
@synthesize program;

+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath
               fragmentShaderPath:(NSString *)fragmentShaderPath
{
    NSString *vertexShaderContent = [NSString stringWithContentsOfFile:vertexShaderPath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    NSString *fragmentShaderContent = [NSString stringWithContentsOfFile:fragmentShaderPath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:nil];
    return [[GLContext alloc] initWithVertexShader:vertexShaderContent
                                    fragmentShader:fragmentShaderContent];
}

- (id)initWithVertexShader:(NSString *)vertexShader
            fragmentShader:(NSString *)fragmentShader
{
    self = [self init];
    
    if (self) {
        
        [self setupShader:vertexShader fragmentShader:fragmentShader];
        
        return self;
    }
    
    return nil;
}

- (void)active
{
    glUseProgram(self.program);
}

- (void)bindAttribs:(GLfloat *)triangleData
{
    GLuint position = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(position);
    GLuint color = glGetAttribLocation(program, "normal");
    glEnableVertexAttribArray(color);
    GLuint uv = glGetAttribLocation(program, "uv");
    glEnableVertexAttribArray(uv);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData);
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 3 * sizeof(GLfloat));
    glVertexAttribPointer(uv, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 6 * sizeof(GLfloat));
}

- (void)drawTriangle:(GLfloat *)triangleData vertexCount:(GLint)vertexCount
{
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void)drawTriangleWithVBO:(GLuint)vbo vertexCount:(GLint)vertexCount
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    [self bindAttribs:NULL];
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void)drawTriangleWithVAO:(GLuint)vao vertexCount:(GLint)vertexCount
{
    glBindVertexArrayOES(vao);
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void)drawGeometry:(GLGeometry *)geometry
{
    glBindBuffer(GL_ARRAY_BUFFER, [geometry getVBO]);
    [self bindAttribs:NULL];
    if (geometry.geometryType == GLGeometryTypeTriangleFan) {
        glDrawArrays(GL_TRIANGLE_FAN, 0, [geometry vertexCount]);
    }else if (geometry.geometryType == GLGeometryTypeTriangles){
        glDrawArrays(GL_TRIANGLES, 0, [geometry vertexCount]);
    }else if (geometry.geometryType == GLGeometryTypeTriangleStrip){
        glDrawArrays(GL_TRIANGLE_STRIP, 0, [geometry vertexCount]);
    }
}

#pragma mark - Uniform Setter
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform1i(location, value);
}

- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform1f(location, value);
}

- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform3fv(location, 1, value.v);
}

- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniformMatrix4fv(location, 1, 0, value.m);
}

#pragma mark - Texture
- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName {
    glActiveTexture(textureChannel);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    GLuint textureID = (GLuint)textureChannel - (GLuint)GL_TEXTURE0;
    [self setUniform1i:uniformName value:textureID];
}

#pragma mark - Prepare Shader
bool createProgram(const char *vertexShader, const char *fragmentShader, GLuint *pProgram) {
    GLuint program, vertShader, fragShader;
    // Create shader program.
    program = glCreateProgram();
    
    const GLchar *vssource = (GLchar *)vertexShader;
    const GLchar *fssource = (GLchar *)fragmentShader;
    
    if (!compileShader(&vertShader,GL_VERTEX_SHADER, vssource)) {
        printf("Failed to compile vertex shader");
        return false;
    }
    
    if (!compileShader(&fragShader,GL_FRAGMENT_SHADER, fssource)) {
        printf("Failed to compile fragment shader");
        return false;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Link program.
    if (!linkProgram(program)) {
        printf("Failed to link program: %d", program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return false;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    *pProgram = program;
    printf("Effect build success => %d \n", program);
    return true;
}


bool compileShader(GLuint *shader, GLenum type, const GLchar *source) {
    GLint status;
    
    if (!source) {
        printf("Failed to load vertex shader");
        return false;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    
#if DEBUG
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s", log);
        printf("Shader: \n %s\n", source);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }
    
    return true;
}

bool linkProgram(GLuint prog) {
    GLint status;
    glLinkProgram(prog);
    
#if DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}

bool validateProgram(GLuint prog) {
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}

- (void)setupShader:(NSString *)vertexShaderContent fragmentShader:(NSString *)fragmentShaderContent {
    createProgram(vertexShaderContent.UTF8String, fragmentShaderContent.UTF8String, &program);
}

@end
