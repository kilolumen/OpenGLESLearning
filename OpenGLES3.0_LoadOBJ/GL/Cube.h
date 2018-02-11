//
//  Cube.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/8.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//  how

#import "GLObject.h"

@interface Cube : GLObject
- (id)initWithGLContext:(GLContext *)context            //GL环境
             diffuseMap:(GLKTextureInfo *)diffuseMap    //漫反射贴图
              normalMap:(GLKTextureInfo *)normalMap;    //法线贴图
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
