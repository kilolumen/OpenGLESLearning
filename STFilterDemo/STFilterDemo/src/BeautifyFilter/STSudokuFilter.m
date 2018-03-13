//
//  STSudokuFilter.m
//  STFilterDemo
//
//  Created by sensetimesunjian on 2018/3/13.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "STSudokuFilter.h"

@implementation STSudokuFilter
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
        -1.0 / 9.0f,  -1.0 / 9.0f,
        1.0  / 9.0f,  -1.0 / 9.0f,
        -1.0 / 9.0f,  1.0 / 9.0f,
        1.0  / 9.0f,  1.0 / 9.0f,
    };
    
    static const GLfloat coordinate1[] = {
        0.0f,  0.0f,
        1.0f,  0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    for(int i = 0; i < 9; ++i){
        GLfloat vertexs[8];
        for(int j = 0; j < 8; ++j){
            vertexs[i] = vertex1[i] * i;
        }
        //render texture1
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform, i);
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertexs);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinate1);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
