//
//  GLObject.h
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/22.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

//  这个类的主要作用是，GLObject基类，例如：圆、线段、正方体、球体等

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "GLContext.h"

@interface GLObject : NSObject
@property (nonatomic, strong) GLContext *context;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;

- (id)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
