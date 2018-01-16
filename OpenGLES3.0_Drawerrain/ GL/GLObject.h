//
//  GLObject.h
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import "GLContext.h"

@interface GLObject : NSObject
@property (nonatomic, strong) GLContext *context;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;

- (id)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
