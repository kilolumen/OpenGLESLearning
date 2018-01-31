//
//  CubeMapViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/31.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "CubeMapViewController.h"
#import "GLContext.h"
#import "WaveFrountOBJ2.h"

typedef struct {
    GLKVector3 direction;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
}DirectionLight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness;
}Material;

@interface CubeMapViewController ()
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;//透视投影
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;//观察矩阵 cameraMatrix * projectionMatrix = 摄像机空间
@property (nonatomic, assign) DirectionLight light;
@property (nonatomic, assign) Material material;
@property (nonatomic, assign) GLKVector3 eyePosition;//观察位置
@property (nonatomic, strong) NSMutableArray <GLObject *> *objects;
@property (nonatomic, assign) BOOL useNormalMap;
@property (nonatomic, strong) GLKTextureInfo *cubeTexture;
@end

@implementation CubeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGLContext];
    
    
    //使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;//手机屏幕横竖比例
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90),//视场角
                                                      aspect,//横竖比例
                                                      0.1,//近平面
                                                      1000.0);//远平面
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1);//白色
    defaultLight.direction = GLKVector3Make(-1, -1, 0);//光线方向
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;//环境光强度
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);//白色
    material.diffuseColor = GLKVector3Make(0.8, 0.1, 0.2);//漫反射光
    material.specularColor = GLKVector3Make(1, 1, 1);//镜面高光白色
    self.material = material;
    
    self.useNormalMap = NO;//不用法线贴图
    
    self.objects = [NSMutableArray array];
    [self createMonkey];
    [self createCubeTexture];
}

- (void)setupGLContext {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex2" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment4" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}


- (void)createMonkey
{
    UIImage *normalImage = [UIImage imageNamed:@"metal.jpg"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"metal.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *objFile = [[NSBundle mainBundle] pathForResource:@"smoothMonkey" ofType:@"obj"];
    WaveFrountOBJ2 *sphere = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:objFile diffuseMap:diffuseMap normalMap:normalMap];
    sphere.modelMatrix = GLKMatrix4Identity;
    [self.objects addObject:sphere];
}

- (void)createCubeTexture
{
    NSMutableArray *files = [NSMutableArray array];
    for (int i = 0; i < 6; ++i) {
        NSString *fileName = [NSString stringWithFormat:@"cube-%d",i+1];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        [files addObject:filePath];
    }
    
    NSError *error;
    self.cubeTexture = [GLKTextureLoader cubeMapWithContentsOfFiles:files options:nil error:&error];
}

#pragma mark - Update Delegate

- (void)update
{
    [super update];
    self.eyePosition = GLKVector3Make(2, 1, 2);//更新观察位置
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,
                                             self.eyePosition.y,
                                             self.eyePosition.z,
                                             lookAtPosition.x,
                                             lookAtPosition.y,
                                             lookAtPosition.z,
                                             0, 1, 0);//更新观察位置
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop)
    {
        obj.modelMatrix = GLKMatrix4MakeRotation(self.elapsedTime, 0, 1, 0);//模型矩阵就是只的3D物体，绕y轴旋转
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)drawObjects
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop) {
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
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        [obj.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE3 uniformName:@"envMap"];
        [obj draw:obj.context];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}

@end
