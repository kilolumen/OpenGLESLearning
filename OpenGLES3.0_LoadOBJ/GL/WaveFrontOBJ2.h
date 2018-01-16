//
//  WaveFrontOBJ2.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by 孙健 on 2018/1/17.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//  归根结底是因为你懒 不想动脑子 是一种排斥 方法就是坚持 控制自己的行为

#import "GLObject.h"

@interface WaveFrontOBJ2 : GLObject
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;

@end
