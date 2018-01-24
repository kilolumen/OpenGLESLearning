//
//  GLBaseViewController.m
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/23.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLBaseViewController.h"
#import "GLContext.h"

@interface GLBaseViewController ()
@property (nonatomic, strong) EAGLContext *context;
@end

@implementation GLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self setupGLContext];
}

#pragma mark - Setup Context
- (void)setupContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.preferredFramesPerSecond = 60;
    if (!self.context) {
        
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];
    
    //设置OpenGL状态
    glEnable(GL_DEPTH_TEST);
}

- (void)setupGLContext
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}

#pragma mark - Update Delegate
- (void)update
{
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    self.elapsedTime += deltaTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.glContext active];
    
    [self.glContext setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
