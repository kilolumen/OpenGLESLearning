//
//  GLBaseViewController.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/5/10.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLContext;

@interface GLBaseViewController : GLKViewController
@property (nonatomic, strong) GLContext *glContext;
@property (nonatomic, assign) GLfloat elapsedTime;
@property (nonatomic, strong) EAGLContext *context;

- (void)update;
@end
