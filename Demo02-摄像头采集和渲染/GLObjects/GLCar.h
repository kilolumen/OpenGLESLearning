//
//  GLCar.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/14.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObjectLoadFromOBJ.h"

@interface GLCar : GLObjectLoadFromOBJ
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
