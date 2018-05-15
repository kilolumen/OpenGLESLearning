//
//  GLBaseViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/5/10.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLBaseViewController.h"
#import "GLContext.h"

@interface GLBaseViewController ()

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
    //使用OpenGL ES2，ES2之后都采用shader来管理渲染线程
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //设置帧率为60fps
    self.preferredFramesPerSecond = 60;
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    
    GLKView *glView = (GLKView *)self.view;
    glView.context = self.context;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glView.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];
    
    //设置OpenGL状态
    glEnable(GL_DEPTH_TEST);
}

- (void)setupGLContext
{
    NSString *vertexShaderpath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderpath fragmentShaderPath:fragmentShaderPath];
}

- (void)update
{
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    self.elapsedTime += deltaTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //清空之前的缓存
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.glContext active];
    [self.glContext setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
