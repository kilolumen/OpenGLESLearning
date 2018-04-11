//
//  GLSphere.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/4/11.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface GLSphere : NSObject
@property (nonatomic, assign) GLKMatrix4 projectMatrix;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;
- (void)draw;
@end
