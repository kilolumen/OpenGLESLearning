//
//  STMirrorFilter.m
//  STFilterDemo
//
//  Created by sensetimesunjian on 2018/3/12.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "STMirrorFilter.h"

@implementation STMirrorFilter

- (id)init
{
    self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
    
    if (self) {
        
    }
    
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    [GPUImageContext useImageProcessingContext];
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    static const GLfloat vertex1[] = {
        -1.0,  0.0f,
        0.0f,  0.0f,
        -1.0f,  1.0f,
        0.0f,  1.0f,
    };

    static const GLfloat coordinate1[] = {
        0.0f,  0.0f,
        1.0f,  0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };

    //render texture1
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertex1);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinate1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    static const GLfloat vertex2[] = {
         1.0,  0.0f,
        0.0f,  0.0f,
        1.0f,  1.0f,
        0.0f,  1.0f,
    };
    //render texture2
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 3);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertex2);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinate1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    static const GLfloat vertex3[] = {
        -1.0f,  0.0f,
        0.0f,  0.0f,
        -1.0f,  -1.0f,
        0.0f,  -1.0f,
    };
    //render texture2
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 3);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertex3);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinate1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    static const GLfloat vertex4[] = {
         0.0f,  0.0f,
        1.0f,  0.0f,
        0.0f,  -1.0f,
        1.0f,  -1.0f,
    };
    //render texture2
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 3);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertex4);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinate1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
