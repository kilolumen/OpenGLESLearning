//
//  WaveFrontOBJ.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@interface WaveFrontOBJ : GLObject
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
