//
//  STSoulFilter2.m
//  STFilterDemo
//
//  Created by sensetimesunjian on 2018/3/13.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "STSoulFilter2.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageStSoulFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec2 texCoord = textureCoordinate * 2.0;
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, texCoord);
     
     gl_FragColor = mix(textureColor, textureColor2, 0.5);
 }
 );
#else
#endif

@interface STSoulFilter2 ()
{
    GLuint filterInputTextureUniform2;
}
@end

@implementation STSoulFilter2
- (id)init
{
    self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImageStSoulFilterFragmentShaderString];
    
    if (!self) {
        
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"];
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
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO]  textureOptions:self.outputTextureOptions onlyTexture:NO];
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
    
    static GLuint hereTexture = 0;
    if (self.souled) {
        self.souled = NO;
        hereTexture = [firstInputFramebuffer texture];
    }
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, hereTexture);
    glUniform1i(filterInputTextureUniform2, 3);
    
    NSLog(@"sunjian hereTexture is %d, texture is %d", hereTexture, [firstInputFramebuffer texture]);
    
//    glEnableVertexAttribArray(filterPositionAttribute);
//    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
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
