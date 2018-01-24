//
//  normalMapViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/17.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "normalMapViewController.h"
#import "GLContext.h"
#import "WaveFrountOBJ2.h"
#import "Plane.h"

typedef struct {
    GLKVector3 position;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
}PointLight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness;
}Material;

@interface normalMapViewController ()
{
    GLuint frameBuffer;
    GLuint frameBufferColorTexture;
    GLuint frameBufferDepthTexture;
}
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@property (nonatomic, assign) PointLight light;
@property (nonatomic, assign) Material material;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, strong) WaveFrountOBJ2 *carModel;

@property (nonatomic, strong) Plane *displayFrameBufferPlane;
@property (nonatomic, assign) CGSize frameBufferSize;
@property (nonatomic, assign) GLKMatrix4 planeProjectionMatrix;

@property (nonatomic, strong) NSMutableArray <GLObject *> * objects;
@property (nonatomic, assign) BOOL useNormalMap;

@property (nonatomic, strong) NSMutableArray *arrSliders;
@end

@implementation normalMapViewController

- (void)setupUI
{
    
    NSMutableArray *arrSlider = [NSMutableArray array];
    NSMutableArray *arrLabel = [NSMutableArray array];
    NSArray *arrTexts = @[@"光滑度",@"Ambient",@"Diffuse",@"Specular",@"LightColor",@"indensity"];
    
    for(int i = 0; i < 6; ++i){
        
        UISlider *slider = [[UISlider alloc] init];
        [self.view addSubview:slider];
        [arrSlider addObject:slider];
        
        UILabel *lable = [[UILabel alloc] init];
        [self.view addSubview:lable];
        [arrLabel addObject:lable];
    }
    
    for(int j = 0; j < arrSlider.count; ++j){
        
        UISlider *slider = (UISlider *)arrSlider[j];
        slider.frame = CGRectMake(100, self.view.frame.size.height - 54 - j * 30, self.view.frame.size.width - 100, 20);
        [slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        slider.tag = 200 + j;
        
        UILabel *label = (UILabel *)arrLabel[j];
        label.frame = CGRectMake(5, self.view.frame.size.height - 54 - j * 30, 80, 20);
        label.text = arrTexts[j];
    }
}

- (void)valueChange:(UISlider *)sender
{
    switch (sender.tag) {
        case 200:
            [self smoothChanged:sender];
            break;
        
        case 201:
            [self lightColorChanged:sender];
            break;
            
        case 202:
            [self specularChanged:sender];
            break;
            
        case 203:
            [self diffuseChanged:sender];
            break;
            
        case 204:
            [self ambientChanged:sender];
            break;
            
        case 205:
            [self indensityChnaged:sender];
            break;
        default:
            break;
    }
}

- (void)indensityChnaged:(UISlider *)sender
{
    PointLight _light = self.light;
    _light.indensity = sender.value;
    self.light = _light;
}

- (void)lightColorChanged:(UISlider *)sender
{
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    PointLight _light = self.light;
    _light.color = [self colorFormYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _light.color = GLKVector3Make(1, 1, 1);
    }
    self.light = _light;
    sender.backgroundColor = [UIColor colorWithRed:_light.color.r green:_light.color.g blue:_light.color.b alpha:1.0];
}

- (void)specularChanged:(UISlider *)sender
{
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material _material = self.material;
    _material.specularColor = [self colorFormYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _material.specularColor = GLKVector3Make(1, 1, 1);
    }
    self.material = _material;
    sender.backgroundColor = [UIColor colorWithRed:_material.specularColor.r green:_material.specularColor.g blue:_material.specularColor.b alpha:1.0];
}

- (void)diffuseChanged:(UISlider *)sender
{
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material _material = self.material;
    _material.diffuseColor = [self colorFormYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _material.diffuseColor = GLKVector3Make(1, 1, 1);
    }
    if (sender.value == sender.minimumValue) {
        _material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    }
    self.material = _material;
    sender.backgroundColor = [UIColor colorWithRed:_material.diffuseColor.r green:_material.diffuseColor.g blue:_material.diffuseColor.b alpha:1.0];
}

- (void)ambientChanged:(UISlider *)sender
{
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material material = self.material;
    material.ambientColor = [self colorFormYUV:yuv];
    
    if (sender.value == sender.maximumValue) {
        
        material.ambientColor = GLKVector3Make(1, 1, 1);
    }
    
    self.material = material;
    sender.backgroundColor = [UIColor colorWithRed:material.ambientColor.r green:material.ambientColor.g blue:material.ambientColor.g alpha:1.0];
}

- (GLKVector3)colorFormYUV:(GLKVector3)yuv
{
    float Cb, Cr, Y;
    float R, G, B;
    Y = yuv.x * 255.0;
    Cb = yuv.y * 255.0 - 128.0;
    Cr = yuv.z * 255.0 - 128.0;
    
    R = 1.482 * Cr + Y;
    G = -0.344 * Cb - 0.714 * Cr + Y;
    B =1.772 * Cb + Y;
    
    return GLKVector3Make(MIN(1.0, R /255.0), MIN(1.0, G / 255.0), MIN(1.0, B / 255.0));
}



- (void)smoothChanged:(UISlider *)sender
{
    Material material = self.material;
    material.smoothness = sender.value;
    self.material = material;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGLContext];
    
    [self setupUI];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    PointLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.position = GLKVector3Make(30, 100, 0);
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
    
    self.objects = [NSMutableArray new];
    [self createMonkeyFromObj];
    
    self.frameBufferSize = CGSizeMake(512, 512);
    [self createTextureFrameBuffer:self.frameBufferSize];
    [self createPlane];
}

- (void)createTextureFrameBuffer:(CGSize)size
{
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenTextures(1, &frameBufferColorTexture);
    glBindTexture(GL_TEXTURE_2D, frameBufferColorTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameBufferColorTexture, 0);
    
    // 生成深度缓冲区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &frameBufferDepthTexture);
    glBindTexture(GL_TEXTURE_2D, frameBufferDepthTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, size.width, size.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT
                           , GL_TEXTURE_2D, frameBufferDepthTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(frameBuffer);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        
        
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

}

- (void)createPlane
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_framebuffer_plane" ofType:@".glsl"];
    GLContext *displayFrameBufferPlanContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.displayFrameBufferPlane = [[Plane alloc] initWithGLContext:displayFrameBufferPlanContext texture:frameBufferColorTexture];
    self.displayFrameBufferPlane.modelMatrix = GLKMatrix4Identity;
    self.planeProjectionMatrix = GLKMatrix4MakeOrtho(-2.5, 0.5, -4.5, 0.5, -100, 100);
}
- (void)setupGLContext
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex2" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment2" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}

- (void)createMonkeyFromObj {
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    self.carModel = [WaveFrountOBJ2 objWithGLContext:self.glContext objFile:objFilePath diffuseMap:diffuseMap normalMap:normalMap];
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
    [self.objects addObject:self.carModel];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.eyePosition = GLKVector3Make(0, 2, 6);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0 * self.elapsedTime / 4.0, 1, 1, 1);
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)drawObjects
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.position" value:self.light.position];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        
        [obj draw:obj.context];
    }];
}

- (void)drawPlane {
    [self.displayFrameBufferPlane.context active];
    [self.displayFrameBufferPlane.context setUniformMatrix4fv:@"projectionMatrix" value:self.planeProjectionMatrix];
    [self.displayFrameBufferPlane.context setUniformMatrix4fv:@"cameraMatrix" value:GLKMatrix4Identity];
    [self.displayFrameBufferPlane draw:self.displayFrameBufferPlane.context];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
//    [super glkView:view drawInRect:rect];
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glViewport(0, 0, self.frameBufferSize.width, self.frameBufferSize.height);
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), self.frameBufferSize.width / self.frameBufferSize.height, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, sin(self.elapsedTime) * 5.0 + 9.0, 0, 0, 0, 0, 1, 0);
    [self drawObjects];
    
   
    [view bindDrawable];
    glClearColor(0.2, 0.2, 0.2, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    [self drawObjects];
    [self drawPlane];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
