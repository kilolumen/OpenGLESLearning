//
//  HightLevelLuminationVC.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/16.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "HightLevelLuminationVC.h"
#import "GLContext.h"
#import "WaveFrontOBJ.h"


typedef struct {
    GLKVector3 direction;//光线方向
    GLKVector3 color;//光线颜色
    GLfloat indensity;//强度
    GLfloat ambientIndensity;//环境光
}DirectionLight;

typedef struct {
    GLKVector3 diffuseColor;//漫反射光
    GLKVector3 ambientColor;//环境光
    GLKVector3 specularColor;//高光
    GLfloat smoothness;//光滑度
}Material;

@interface HightLevelLuminationVC ()
@property (nonatomic, assign) GLKMatrix4        projectionMatrix;//投影矩阵
@property (nonatomic, assign) GLKMatrix4        cameraMatrix;//观察矩阵
@property (nonatomic, assign) DirectionLight    light;//平行光
@property (nonatomic, assign) Material          material;//素材
@property (nonatomic, assign) GLKVector3        eyePosition;//观察位置
@property (nonatomic, strong) WaveFrontOBJ      *carModel;
@property (nonatomic, strong) NSMutableArray<GLObject *> *ojects;//GL对象 模型矩阵代表世界坐标系
@end

@implementation HightLevelLuminationVC


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGLContext];
    //使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85), aspect, 0.1, 1000.0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1);//黑色
    defaultLight.direction = GLKVector3Make(1, -1, 0);//方向
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);//黑色
    material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 300;
    self.material = material;
    
    
    self.ojects = [NSMutableArray array];
    [self createMonkeyFromObj];
}

- (void)setupGLContext
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment1" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}

- (void)createMonkeyFromObj
{
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"obj"];
    self.carModel = [[WaveFrontOBJ alloc] initWithGLContext:self.glContext objFile:objFilePath];
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
    [self.ojects addObject:self.carModel];
}

- (void)update
{
    [super update];
    self.eyePosition = GLKVector3Make(60, 100, 200);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,
                                             self.eyePosition.y,
                                             self.eyePosition.z,
                                             lookAtPosition.x,
                                             lookAtPosition.y,
                                             lookAtPosition.z,
                                             0, 1, 0);
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0 * self.elapsedTime / 4.0, 0, 1, 0);
    
    [self.ojects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [super glkView:view drawInRect:rect];
    
    [self.ojects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.context active];
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.light.direction];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        [obj draw:obj.context];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
