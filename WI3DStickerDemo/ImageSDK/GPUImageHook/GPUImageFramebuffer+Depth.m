//
//  GPUImageFramebuffer+Depth.m
//  Pods
//
//  Created by ycpeng on 2017/9/8.
//  Copyright © 2017年 ycpeng. All rights reserved.
//

#import "GPUImageFramebuffer+Depth.h"
#import <objc/runtime.h>

static char kDepthBufferKey;

@implementation GPUImageFramebuffer (Depth)

void exchangeMethod(Class aClass, SEL oldSEL, SEL newSEL)
{
    Method oldMethod = class_getInstanceMethod(aClass, oldSEL);
    assert(oldMethod);
    Method newMethod = class_getInstanceMethod(aClass, newSEL);
    assert(newMethod);
    method_exchangeImplementations(oldMethod, newMethod);
}

+ (void)hook
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    exchangeMethod([GPUImageFramebuffer class], @selector(generateFramebuffer), @selector(hook_generateFramebuffer));
    exchangeMethod([GPUImageFramebuffer class], @selector(destroyFramebuffer), @selector(hook_destroyFramebuffer));
#pragma clang diagnostic pop
}

- (void)hook_generateFramebuffer
{
    [self hook_generateFramebuffer];
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        int width = self.size.width;
        int height = self.size.height;
        
        GLuint depthbuffer;
        glGenRenderbuffers(1, &depthbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);
        
        objc_setAssociatedObject(self, &kDepthBufferKey, @(depthbuffer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

- (void)hook_destroyFramebuffer
{
    [self hook_destroyFramebuffer];
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        [self deleteBufferWithKey:&kDepthBufferKey];
    });
}

- (void)deleteBufferWithKey:(const void * _Nonnull)key
{
    GLuint buffer = [objc_getAssociatedObject(self, key) unsignedIntValue];
    if (buffer)
    {
        glDeleteFramebuffers(1, &buffer);
        buffer = 0;
    }
}

@end
