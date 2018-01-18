//
//  WaveFrountOBJ2.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/17.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@interface WaveFrountOBJ2 : GLObject
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;
+ (id)objWithGLContext:(GLContext *)context
               objFile:(NSString *)filePath
            diffuseMap:(GLKTextureInfo *)diffuseMap//漫反射贴图
             normalMap:(GLKTextureInfo *)normalMap;//法线贴图
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
