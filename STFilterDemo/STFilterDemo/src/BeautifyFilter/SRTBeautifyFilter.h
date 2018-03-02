//
//  SRTBeautifyFilter.h
//  shiritan
//
//  Created by Yangtsing.Zhang on 2018/1/23.
//  Copyright © 2018年 Seamus. All rights reserved.
//

#import "GPUImageOutput.h"

@interface SRTBeautifyFilter : GPUImageOutput<GPUImageInput>{
    GPUImageFramebuffer *_1stInputFrameBuffer;
    GPUImageRotationMode _1stInputRotation;
    CGSize _1stInputTextureSize;
    BOOL _hasReceived1stFrame;
    dispatch_semaphore_t _imageCaptureSemaphore;
    
    GLProgram *filterProgram;
    GLint filterPositionAttribute, filterTextureCoordinateAttribute;
    GLint filterInputTextureUniform;
    
    CVPixelBufferRef _cvBeautifyBuffer;
    GLuint _textureBeautifyOutput;
    CVOpenGLESTextureRef _cvTextureBeautify;
    CVOpenGLESTextureCacheRef _cvTextureCache;
}

@end
