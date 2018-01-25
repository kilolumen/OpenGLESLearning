//
//  shadowViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/25.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "shadowViewController.h"
#import "GLContext.h"
#import "WaveFrountOBJ2.h"

typedef struct {
    GLKVector3 direction;
    GLKVector3 color;
    GLfloat    indensity;
    GLfloat    ambientIndensity;
}DirectionLight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness;
}Material;

@interface shadowViewController ()
{
    GLuint shadowMapFramebuffer;
    GLuint shadowDepthMap;
}
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;//透视投影矩阵
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;//观察矩阵
@property (nonatomic, assign) DirectionLight light;//光线
@property (nonatomic, assign) Material material;//材质
@property (nonatomic, assign) GLKVector3 eyePosition;//观察位置
@property (nonatomic, strong) NSMutableArray<GLObject *> *objects;//GL对象
@property (nonatomic, assign) BOOL useNormalMap;//是否使用法线贴图

//投影器矩阵
@property (nonatomic, assign) GLKMatrix4 lightProjectionMatrix;
@property (nonatomic, assign) GLKMatrix4 lightCameraMatrix;
@property (nonatomic, assign) CGSize     shadowMapSize;
@property (nonatomic, strong) GLContext  *shadowMapContext;//用来配置GPU程序
@end

@implementation shadowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGLContext];
    
    //使用透视投影
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);//透视投影矩阵，1.视场角 2.横宽比例 3.近平面 4.远平面
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);//观察矩阵 1.摄像机位置 2.看向的位置 3.摄像机的方向
    
    DirectionLight defaultLight;//设置光源参数
    defaultLight.color = GLKVector3Make(1, 1, 1);//光源的颜色
    defaultLight.direction = GLKVector3Make(-1, -1, 0);//光线方向
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 70;
    self.material = material;
    
    self.useNormalMap = YES;
    
    self.objects = [NSMutableArray array];
    [self createBox:GLKVector3Make(-1, 0.6, -1.3) size:GLKVector3Make(0.6, 0.6, 0.6)];
    [self createBox:GLKVector3Make(2, 1, 1) size:GLKVector3Make(0.4, 1, 0.4)];
    [self createBox:GLKVector3Make(0.2, 1.3, 0.8) size: GLKVector3Make(0.3, 1.3, 0.4)];
    [self createFloor];
    
    //投影器矩阵
    self.lightProjectionMatrix = GLKMatrix4MakeOrtho(-10, 10, -10, 10, -100, 100);//下上左右 前后
    self.lightCameraMatrix = GLKMatrix4MakeLookAt(-defaultLight.direction.x * 10, -defaultLight.direction.y * 10, -defaultLight.direction.z * 10, 0, 0, 0, 0, 1, 0);
    
    //创建投影纹理
    [self createShadowMap];
}

- (void)setupGLContext
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertexShadow" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragmentShadow" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    NSString *vertexShaderPath1 = [[NSBundle mainBundle] pathForResource:@"vertexShadow" ofType:@".glsl"];
    NSString *fragmentShaderPath1 = [[NSBundle mainBundle] pathForResource:@"frag_shadowmap" ofType:@".glsl"];
    self.shadowMapContext = [GLContext contextWithVertexShaderPath:vertexShaderPath1 fragmentShaderPath:fragmentShaderPath1];
}

- (void)createShadowMap
{
    self.shadowMapSize = CGSizeMake(1024, 1024);
    glGenFramebuffers(1, &shadowMapFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFramebuffer);
    
    glGenTextures(1, &shadowDepthMap);
    glBindTexture(GL_TEXTURE_2D, shadowDepthMap);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, self.shadowMapSize.width, self.shadowMapSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, shadowDepthMap, 0);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        //framebuffer生成失败
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}

- (void)createFloor
{
    UIImage *normalImage = [UIImage imageNamed:@"stoneFloor_NRM.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"stoneFloor.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WaveFrountOBJ2 *cube = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, -0.1, 0), GLKMatrix4MakeScale(3, 0.2, 3));
    [self.objects addObject:cube];
}

- (void)createBox:(GLKVector3)location size:(GLKVector3)size
{
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WaveFrountOBJ2 *cube = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4MakeTranslation(location.x, location.y, location.z);
    cube.modelMatrix = GLKMatrix4Multiply(cube.modelMatrix, GLKMatrix4MakeScale(size.x, size.y, size.z));
    [self.objects addObject:cube];
}

#pragma mark - Update Delegate
- (void)update
{
    [super update];
    
    self.eyePosition = GLKVector3Make(1, 4, 4);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    DirectionLight light = self.light;
    light.direction = GLKVector3Make(-sin(self.elapsedTime), -1, -cos(self.elapsedTime));
    self.light = light;
    self.lightProjectionMatrix = GLKMatrix4MakeOrtho(-10, 10, -10, 10, -100, 100);
    self.lightCameraMatrix = GLKMatrix4MakeLookAt(-light.direction.x * 10, -light.direction.y * 10, -light.direction.z * 10, 0, 0, 0, 0, 1, 0);
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
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
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        [obj.context setUniformMatrix4fv:@"lightMatrix" value:GLKMatrix4Multiply(self.lightProjectionMatrix, self.lightCameraMatrix)];
        [obj.context bindTextureName:shadowDepthMap to:GL_TEXTURE2 uniformName:@"shadowMap"];
        [obj draw:obj.context];
    }];
}

- (void)drawObjectsForShadowMap
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.shadowMapContext active];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.lightProjectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.lightCameraMatrix];
        [obj draw:self.shadowMapContext];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFramebuffer);
    glViewport(0, 0, self.shadowMapSize.width, self.shadowMapSize.height);
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjectsForShadowMap];
    
    [(GLKView *)(self.view) bindDrawable];
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
