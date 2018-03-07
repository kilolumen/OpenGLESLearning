//
//  GLObject.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "GLContext.h"

@interface GLObject : NSObject
@property (nonatomic, strong) GLContext *context;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;
- (instancetype)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
