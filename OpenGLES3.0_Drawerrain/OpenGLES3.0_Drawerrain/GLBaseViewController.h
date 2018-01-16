//
//  GLBaseViewController.h
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/12.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GLContext.h"

@interface GLBaseViewController : GLKViewController
@property (strong, nonatomic) GLContext * glContext;
@property (assign, nonatomic) GLfloat elapsedTime;

- (void)update;
- (void)bindAttribs:(GLfloat *)triangleData;
@end
