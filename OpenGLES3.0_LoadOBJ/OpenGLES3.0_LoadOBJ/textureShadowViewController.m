//
//  textureShadowViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "textureShadowViewController.h"
#import "GLContext.h"
#import "WaveFrountOBJ2.h"

typedef struct {
    GLKVector3 direction;//光线方向
    GLKVector3 color;//点光源方向
    GLfloat indensity;//点光源强度
    GLfloat ambientIndensity;//环境光强度
}PointLight;

typedef struct {
    GLKVector3 diffuseColor;//漫反射光
    GLKVector3 ambientColor;//环境光颜色
    GLKVector3 specularColor;//镜面高光
    GLfloat smoothness;//光滑度
}Material;//材质

@interface textureShadowViewController ()
{
    GLuint frameBuffer;//帧缓存，用来存放屏幕显示数据
    GLuint frameBufferColorTexture;//颜色纹理
    GLuint frameBufferDepthTexture;//深度纹理
}
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;//投影矩阵
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;//相机矩阵
@property (nonatomic, assign) PointLight light;//灯光
@property (nonatomic, assign) Material material;//材质
@property (nonatomic, assign) GLKVector3 eyePosition;//观察位置
@property (nonatomic, strong) NSMutableArray<GLObject *> *objects;//openGL对象
@property (nonatomic, assign) BOOL useNormalMap;//是否用法线贴图
//投影矩阵
@property (nonatomic, assign) GLKMatrix4 projectorMatrix;//投影矩阵
@property (nonatomic, strong) GLKTextureInfo *projectorMap;//投影纹理
@property (nonatomic, assign) BOOL usePorjector;//是否使用投影纹理
@end

@implementation textureShadowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    PointLight defaultLight;//设置光源
    defaultLight.color = GLKVector3Make(1, 1, 1);
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 70;
    self.material = material;
    
    //最终屏幕上的每个像素都是由这些点的颜色组成的
    
    self.useNormalMap = YES;//使用法线贴图
    self.objects = [NSMutableArray array];
    [self createBox:GLKVector3Make(-1, 0.5, -1.3)];
    [self createBox:GLKVector3Make(1, 0.2, 1)];
    [self createFloor];
    
    GLKMatrix4 projectorProjectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -100, 100);//投影空间正交投影矩阵
    GLKMatrix4 projectorCameraMatrix = GLKMatrix4MakeLookAt(0.4, 4, 0, 0, 0, 0, 0, 1, 0);//投影空间的摄像机矩阵
    self.projectorMatrix = GLKMatrix4Multiply(projectorProjectionMatrix, projectorCameraMatrix);//投影空间的vp矩阵
    
    UIImage *projectorImage = [UIImage imageNamed:@"squarepants.jpg"];//投影纹理
    self.projectorMap = [GLKTextureLoader textureWithCGImage:projectorImage.CGImage options:nil error:nil];
    
    self.usePorjector = YES;
}

- (void)createBox:(GLKVector3)location
{
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WaveFrountOBJ2 *cube = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4MakeTranslation(location.x, location.y, location.z);
    [self.objects addObject:cube];
}

- (void)createFloor
{
    UIImage *normalImage = [UIImage imageNamed:@"stoneFloor_NRM.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"stoneFloor.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WaveFrountOBJ2 *cube = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, -0.1, 0), GLKMatrix4MakeScale(3, 0.2, 3));//模型矩阵，沿y轴负方向移动0.1
    [self.objects addObject:cube];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Update Delegate
- (void)update
{
    [super  update];
    self.eyePosition = GLKVector3Make(1, 4, 4);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)drawObjects
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.light.direction];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        [obj.context setUniformMatrix4fv:@"projectorMatrix" value:self.projectionMatrix];
        [obj.context bindTexture:self.projectorMap to:GL_TEXTURE2 uniformName:@"projectionMap"];
        [obj.context setUniform1i:@"useProjector" value:self.usePorjector];
        [obj draw:obj.context];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}

@end
