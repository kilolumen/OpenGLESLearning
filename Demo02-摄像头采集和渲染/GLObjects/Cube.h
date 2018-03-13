//
//  Cube.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/11.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface Cube : GLObject
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
