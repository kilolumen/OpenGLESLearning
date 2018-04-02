//
//  MirrorCamer.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/22.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "MirrorCamer.h"
#import <OpenGLES/ES2/glext.h>
#import "GLBox.h"
#import "Mirror.h"
#import "Camera.h"

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
} Material;

@interface MirrorCamer ()
{
    int _backingWidht;
    int _backingHeight;
    EAGLContext *_context;
    
    GLuint _frameBuffer;
    GLuint _depthBuffer;
}

@property (nonatomic, strong) GLContext *context;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;//投影矩阵
@property (nonatomic, assign) GLKMatrix4 cameraMatrx;//观察矩阵
@property (nonatomic, assign) GLKMatrix4 mirrorProjectionMatrix;//Miiror投影矩阵
@property (nonatomic, assign) GLKMatrix4 viewProjectionMatrix;//视图投影矩阵
@property (nonatomic, assign) DirectionLight light;
@property (nonatomic, assign) Material material;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, strong) NSMutableArray<GLObject *>*objects;
@property (nonatomic, assign) BOOL useNormalMap;
@property (nonatomic, strong) GLKTextureInfo *cubeTexture;
@property (nonatomic, strong) Mirror *mirror;
@property (nonatomic, strong) Camera *mainCamera;
@property (nonatomic, strong) Camera *mirrorCamera;
@property (nonatomic, assign) BOOL clipplaneEnable;
@property (nonatomic, assign) GLKVector4 clipplane;

@end

@implementation MirrorCamer

- (id)initWithContext:(EAGLContext *)context width:(int)width height:(int)height
{
    if (!(self = [super init])) {
        
        return nil;
    }
    
    _context = context;
    _backingWidht = width;
    _backingHeight = height;
    
    [self createFrameBuffer];
    
    [self createGLObjects];
    
    return self;
}

- (void)createFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glBindRenderbuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _backingWidht, _backingHeight, 0, GL_RGBA, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_COMPONENT, GL_TEXTURE_2D, _texture, 0);
    
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidht, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        // framebuffer生成失败
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)createGLObjects
{
    
    
    self.viewProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), self.aspect, 0.1, 1000.0);
    self.mainCamera = [Camera new];
    self.mirrorCamera = [Camera new];
    [self.mainCamera setupCameraWithEye:GLKVector3Make(0, 1, 6.5) lookAt:GLKVector3Make(0, 0, 0) up:GLKVector3Make(0, 1, 0)];
    self.mirrorProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 1, 0.1, 1000.0);
    self.projectionMatrix = self.viewProjectionMatrix;
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.8, 0.1, 0.2);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 20;
    self.material = material;
    
    self.useNormalMap = YES;
    
    self.objects = [NSMutableArray new];
    [self createFloor];
    [self createWall];
    [self createCubes];
    [self createMirror];
}

- (void)createFloor
{
    UIImage *normalImage = [UIImage imageNamed:@"stoneFloor_NRM.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"stoneFloor.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    NSString *objFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
}

- (void)createWall
{
    
}

- (void)createCubes
{
    
}

- (void)createMirror
{
    
}

- (void)render
{
    
}
@end
