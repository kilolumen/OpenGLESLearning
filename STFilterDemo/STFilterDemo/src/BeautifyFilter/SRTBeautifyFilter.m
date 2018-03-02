//
//  SRTBeautifyFilter.m
//  shiritan
//
//  Created by Yangtsing.Zhang on 2018/1/23.
//  Copyright © 2018年 Seamus. All rights reserved.
//

#import "SRTBeautifyFilter.h"
#import "SRTSenseTimeSDKWrapper.h"
#import "st_mobile_human_action.h"
#import "SRTPerformanceHelper.h"
#import "GPUImage.h"
#import "CommonDefine.h"

#define SRT_CONST_U_CHAR const unsigned char

SRT_EXTERN NSString *const kGPUImageVertexShaderString;
SRT_EXTERN NSString *const kGPUImagePassthroughFragmentShaderString;

@implementation SRTBeautifyFilter

#pragma mark - Life cycle
- (void)dealloc{
    [self releaseResultTexture];
    if (_cvTextureCache) {
        CFRelease(_cvTextureCache);
        _cvTextureCache = NULL;
    }
}

- (instancetype)init{
    if (self = [super init]) {
        _imageCaptureSemaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(_imageCaptureSemaphore);
        _1stInputRotation = kGPUImageNoRotation;
        [self initPassThroughGLProgram];
        self.enabled = YES;
    }
    return self;
}

///创建1个直通的着色器程序
- (void)initPassThroughGLProgram{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString: kGPUImageVertexShaderString fragmentShaderString: kGPUImagePassthroughFragmentShaderString];
        
        if (!filterProgram.initialized)
        {
            [self initializeAttributes];
            
            if (![filterProgram link])
            {
                NSString *progLog = [filterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    });
}

- (void)initializeAttributes;
{
    [filterProgram addAttribute:@"position"];
    [filterProgram addAttribute:@"inputTextureCoordinate"];
    
    // Override this, calling back to this super method, in order to add new attributes to your vertex shader
}


#pragma mark - Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates{
    
    //人脸检测
    CVPixelBufferRef srcBuffer = [_1stInputFrameBuffer renderBuffer];
    CVPixelBufferLockBaseAddress(srcBuffer, 0);
    SRT_CONST_U_CHAR *pRGBAImageIn = CVPixelBufferGetBaseAddress(srcBuffer);
    
    //GLubyte *pFBO = [_1stInputFrameBuffer byteBuffer];
    //SRT_CONST_U_CHAR *pRGBAImageIn = (SRT_CONST_U_CHAR *)pFBO;
    int iWidth = (int)_1stInputFrameBuffer.size.width;
    int iHeight = (int)_1stInputFrameBuffer.size.height;
    int bytesPerRow = (int)[_1stInputFrameBuffer bytesPerRow];
    GPUImageRotationMode rotation = _1stInputRotation;
    
    
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    
    uint64_t begin = mach_absolute_time();
    [SRTSenseTimeSDKWrapper_Instance detectFaceInImage: pRGBAImageIn
                                                 width: iWidth
                                                height: iHeight
                                           bytesPerRow: bytesPerRow
                                              rotation: rotation
                                             detectRet: &detectResult];
    uint64_t end = mach_absolute_time();
    double seconds = [SRTPerformanceHelper machTimeToSeconds: (end - begin)];
    devLog(@"detectFace time elapsed: %g s", seconds);
    CVPixelBufferUnlockBaseAddress(srcBuffer, 0);
    devLog(@"检测到的人脸数目: %d", detectResult.face_count);

    [SRTSenseTimeSDKWrapper_Instance useSensetimeGLContext];
    
    //美颜
    if (_cvTextureCache == NULL) {
        // 初始化纹理缓存
        _cvTextureCache = [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache];
    }
    
    if (overrideInputSize == YES) {
        // 当图像尺寸发生改变时需要对应改变纹理大小
        [self releaseResultTexture];
        [self initResultTexture];
    }
    
    begin = mach_absolute_time();
    [SRTSenseTimeSDKWrapper_Instance beautifyTexture: _1stInputFrameBuffer.texture
                                          retTexture: _textureBeautifyOutput
                                               width: iWidth
                                              height: iHeight
                                       faceDetectRet: &detectResult];
    
    end = mach_absolute_time();
    seconds = [SRTPerformanceHelper machTimeToSeconds: (end - begin)];
    devLog(@"beautify time elapsed: %g s", seconds);
    
    //UIImage *beautyImg = [self imageFromPixelBuffer: _cvBeautifyBuffer];
    
    
    CGSize framebufferSize = [self sizeOfFBO];
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize: framebufferSize textureOptions: self.outputTextureOptions onlyTexture: NO];
    
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }

    glClearColor(0, 0, 0 , 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE2);
    //绑定源图像纹理--测试
    //glBindTexture(GL_TEXTURE_2D, _1stInputFrameBuffer.texture);
    //UIImage *srcImg = [self imageFromPixelBuffer: srcBuffer];
    
    
    //将美颜处理好的的纹理绑定到纹理单元
    glBindTexture(GL_TEXTURE_2D, _textureBeautifyOutput);
    glEnable(GL_BLEND);
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glUniform1i(filterInputTextureUniform, 2);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    CVPixelBufferRef outputBuffer = [outputFramebuffer renderBuffer];
//    UIImage *outputImg = [self imageFromPixelBuffer: outputBuffer];
    
    if (usingNextFrameForImageCapture) {
        
        dispatch_semaphore_signal(_imageCaptureSemaphore);
    }
}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer =  pixelBufferRef;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}



- (void)initResultTexture {
    // 创建结果纹理
    CGSize sizeOfFBO = [self sizeOfFBO];
    
    [self setupTextureWithPixelBuffer:&_cvBeautifyBuffer
                                    w: sizeOfFBO.width
                                    h: sizeOfFBO.height
                            glTexture:&_textureBeautifyOutput
                            cvTexture:&_cvTextureBeautify];
}

- (void)releaseResultTexture {
    _textureBeautifyOutput = 0;

    CVPixelBufferRelease(_cvTextureBeautify);
    _cvTextureBeautify = NULL;
    
    CVPixelBufferRelease(_cvBeautifyBuffer);
    _cvBeautifyBuffer = NULL;
}

- (BOOL)setupTextureWithPixelBuffer:(CVPixelBufferRef *)pixelBufferOut
                                  w:(int)iWidth
                                  h:(int)iHeight
                          glTexture:(GLuint *)glTexture
                          cvTexture:(CVOpenGLESTextureRef *)cvTexture {
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault,
                                               NULL,
                                               NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                             1,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn cvRet = CVPixelBufferCreate(kCFAllocatorDefault,
                                         iWidth,
                                         iHeight,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         pixelBufferOut);
    
    if (kCVReturnSuccess != cvRet) {
        
        devLog(@"CVPixelBufferCreate %d" , cvRet);
    }
    
    CGSize sizeOfFBO = [self sizeOfFBO];
    cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         _cvTextureCache,
                                                         *pixelBufferOut,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         sizeOfFBO.width,
                                                         sizeOfFBO.height,
                                                         GL_RGBA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         cvTexture);
    
    CFRelease(attrs);
    CFRelease(empty);
    
    if (kCVReturnSuccess != cvRet) {
        
        devLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    *glTexture = CVOpenGLESTextureGetName(*cvTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(*cvTexture), *glTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


#pragma mark - Inner Logic
- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
{
    if (self.frameProcessingCompletionBlock != NULL)
    {
        self.frameProcessingCompletionBlock(self, frameTime);
    }
    
    // Get all targets the framebuffer so they can grab a lock on it
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
            [currentTarget setInputSize:[self outputFrameSize] atIndex:textureIndex];
        }
    }
    
    // Release our hold so it can return to the cache immediately upon processing
    [[self framebufferForOutput] unlock];
    
    if (usingNextFrameForImageCapture)
    {
    //usingNextFrameForImageCapture = NO;
    }
    else
    {
        [self removeOutputFramebuffer];
    }
    
    // Trigger processing last, so that our unlock comes first in serial execution, avoiding the need for a callback
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (CGSize)outputFrameSize;
{
    return inputTextureSize;
}

- (CGSize)sizeOfFBO;
{
    CGSize outputSize = [self maximumOutputSize];
    if ( (CGSizeEqualToSize(outputSize, CGSizeZero)) || (inputTextureSize.width < outputSize.width) )
    {
        return inputTextureSize;
    }
    else
    {
        return outputSize;
    }
}

+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode;
{
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f,  1.0f,
        0.0f,  1.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    switch(rotationMode)
    {
        case kGPUImageNoRotation: return noRotationTextureCoordinates;
        case kGPUImageRotateLeft: return rotateLeftTextureCoordinates;
        case kGPUImageRotateRight: return rotateRightTextureCoordinates;
        case kGPUImageFlipVertical: return verticalFlipTextureCoordinates;
        case kGPUImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case kGPUImageRotate180: return rotate180TextureCoordinates;
    }
}

#pragma mark- Still image processing

- (void)useNextFrameForImageCapture;
{
    usingNextFrameForImageCapture = YES;
    
    // Set the semaphore high, if it isn't already
    if (dispatch_semaphore_wait(_imageCaptureSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
}

- (CGImageRef)newCGImageFromCurrentlyProcessedOutput
{
    // Give it three seconds to process, then abort if they forgot to set up the image capture properly
    double timeoutForImageCapture = 20.0;
    dispatch_time_t convertedTimeout = dispatch_time(DISPATCH_TIME_NOW, timeoutForImageCapture * NSEC_PER_SEC);
    
    if (dispatch_semaphore_wait(_imageCaptureSemaphore, convertedTimeout) != 0)
    {
        return NULL;
    }
    
    GPUImageFramebuffer* framebuffer = [self framebufferForOutput];
    
    usingNextFrameForImageCapture = NO;
    dispatch_semaphore_signal(_imageCaptureSemaphore);
    
    CGImageRef image = [framebuffer newCGImageFromFramebufferContents];
    return image;
}


#pragma mark - <GPUImageInput> Protocol
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    if (self.enabled == NO) {
        return;
    }
    CMTime passOnFrameTime = frameTime;
    //openGL坐标
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat *textureCoord = [[self class] textureCoordinatesForRotation: _1stInputRotation];
    
    /*
    const GLfloat imgVertCoord[] = {
        -0.5f, -0.228488028,
        1.0f, -0.228488028,
        -0.5f, 0.228488028,
        1.0f, 0.228488028,
    };
    */
    [self renderToTextureWithVertices:imageVertices textureCoordinates: textureCoord];
    
    //通知下级流水线
    [self informTargetsAboutNewFrameAtTime: passOnFrameTime];
    devLog(@"已处理，通知下级流水线");
    
    //释放FrameBuffer
    [_1stInputFrameBuffer unlock];
    _hasReceived1stFrame = NO;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex{
    _hasReceived1stFrame = YES;
    _1stInputFrameBuffer = newInputFramebuffer;
    [_1stInputFrameBuffer lock];
}

- (NSInteger)nextAvailableTextureIndex{
    return 0;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex{
    if (!CGSizeEqualToSize(newSize, _1stInputTextureSize)) {
        _1stInputTextureSize = newSize;
        inputTextureSize = newSize;
        overrideInputSize = YES;
    }else{
        overrideInputSize = NO;
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex{
    _1stInputRotation = newInputRotation;
}

- (void)endProcessing{
    self.enabled = NO;
}

- (BOOL)shouldIgnoreUpdatesToThisTarget{
    return !self.enabled;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue{
    
}

- (CGSize)maximumOutputSize {
    if (CGSizeEqualToSize(_1stInputTextureSize, CGSizeZero)) {
        return CGSizeMake(1280, 720);
    }else
        return _1stInputTextureSize;
}


- (BOOL)wantsMonochromeInput {
    return NO;
}

@end
