//
//  Plane.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/18.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@interface Plane : GLObject
- (instancetype)initWithGLContext:(GLContext *)context
                          texture:(GLuint)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
