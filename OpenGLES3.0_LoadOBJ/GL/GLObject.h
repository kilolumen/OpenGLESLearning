//
//  GLObject.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "GLContext.h"

@interface GLObject : NSObject
@property (nonatomic, strong) GLContext *context;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;//代表时间坐标系
- (id)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
