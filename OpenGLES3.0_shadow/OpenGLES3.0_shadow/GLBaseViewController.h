//
//  GLBaseViewController.h
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <GLKit/GLKit.h>

@class  GLContext;
@interface GLBaseViewController : GLKViewController
@property (nonatomic, strong) GLContext *glContext;
@property (nonatomic, assign) GLfloat elapsedTime;

- (void)update;
- (void)bindAttribs:(GLfloat *)triangleData;
@end
