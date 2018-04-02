//
//  MirrorCamer.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/22.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface MirrorCamer : NSObject
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) float aspect;

- (id)initWithContext:(EAGLContext *)context width:(int)width height:(int)height;
- (void)render;
@end
