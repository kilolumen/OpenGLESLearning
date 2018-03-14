//
//  STSoulFilter.m
//  STFilterDemo
//
//  Created by sensetimesunjian on 2018/3/13.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "STSoulFilter.h"

// Hardcode the vertex shader for standard filters, but this can be overridden
NSString *const kGPUImageSoulVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

NSString *const kGPUImageSoulPassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 void main()
 {
     
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);
     
     gl_FragColor = mix(textureColor, textureColor2, 0.5);
 }
 );

#else
#endif

@interface STSoulFilter ()
{
    //program
    GLint filterInputTextrueUniform2;
    GPUImageFramebuffer *outputFramebufferSoul;
    
    //program2
    GLProgram *filterProgramSoul;
    GLint filterPositionAttributeSoul, filterTextureCoordinateAttributeSoul;
    GLint filterInputTextureUniformSoul;
}
@end

@implementation STSoulFilter

- (id)init
{
    self = [super init];
    
    if (!(self = [super initWithVertexShaderFromString:kGPUImageSoulVertexShaderString fragmentShaderFromString:kGPUImageSoulPassthroughFragmentShaderString]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        //program attribute uniform
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"];
        filterInputTextrueUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"];
        
        [GPUImageContext setActiveShaderProgram:filterProgram];
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        
        //filterProgram attribute uniform
        filterProgramSoul = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        
        if (!filterProgramSoul.initialized)
        {
            [filterProgramSoul addAttribute:@"position"];
            [filterProgramSoul addAttribute:@"inputTextureCoordinate"];
            
            if (![filterProgramSoul link])
            {
                NSString *progLog = [filterProgramSoul programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgramSoul fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgramSoul vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgramSoul = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttributeSoul = [filterProgramSoul attributeIndex:@"position"];
        filterTextureCoordinateAttributeSoul = [filterProgramSoul attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniformSoul = [filterProgramSoul uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        
        [GPUImageContext setActiveShaderProgram:filterProgramSoul];
        
        glEnableVertexAttribArray(filterPositionAttributeSoul);
        glEnableVertexAttribArray(filterTextureCoordinateAttributeSoul);
    });
    
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    //program2
    [GPUImageContext setActiveShaderProgram:filterProgramSoul];
    outputFramebufferSoul = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 3);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
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
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}
@end
