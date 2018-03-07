//
//  GLBox.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface GLBox : GLObject
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;
+ (id)objWithGLContext:(GLContext *)context
               objFile:(NSString *)filePath
            diffuseMap:(GLKTextureInfo *)diffuseMap
             normalMap:(GLKTextureInfo *)normalMap;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
