//
//  ViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "LoadOBJViewController.h"
#import "GLContext.h"
#import "WaveFrontOBJ.h"

@interface LoadOBJViewController ()
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;//投影矩阵
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@property (nonatomic, assign) GLKVector3 lightDirection;
@property (nonatomic, strong) NSMutableArray<GLObject *>* objects;
@end

@implementation LoadOBJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGLContext];
    
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    self.lightDirection = GLKVector3Make(1, -1, 0);
    
    self.objects = [NSMutableArray array];
    
    [self createMonkeyFromObj];
}

- (void)setupGLContext
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}


- (void)createMonkeyFromObj
{
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"obj"];
    WaveFrontOBJ *monkeyModel = [[WaveFrontOBJ alloc] initWithGLContext:self.glContext objFile:objFilePath];
    monkeyModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
    [self.objects addObject:monkeyModel];
}

- (void)update
{
    [super update];
    GLKVector3 eyePosition = GLKVector3Make(200 * sin(self.elapsedTime), 100, 200 * cos(self.elapsedTime));
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        
        [obj.context setUniform3fv:@"lightDirection" value:self.lightDirection];
        [obj draw:obj.context];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
