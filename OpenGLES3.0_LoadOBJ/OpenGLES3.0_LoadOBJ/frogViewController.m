//
//  frogViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/12.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "frogViewController.h"
#import "GLContext.h"
#import "WaveFrountOBJ2.h"
#import "SkyBox.h"
#import "Terrain.h"

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

typedef enum : NSUInteger{
    FogTypeLinear = 0,
    FogTyepExp,
    FogTypeExpSquare,
}FogType;

typedef struct{
    FogType fogType;
    GLfloat fogStart;
    GLfloat fogEnd;
    GLfloat fogIndensity;
    GLKVector3 fogColor;
}Fog;

@interface frogViewController()
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@property (nonatomic, assign) DirectionLight light;
@property (nonatomic, assign) Material material;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, strong) NSMutableArray<GLObject *> *objects;
@property (nonatomic, assign) BOOL useNormalMap;
@property (nonatomic, strong) GLKTextureInfo *cubeTexture;
@property (nonatomic, strong) SkyBox *skyBox;
@property (nonatomic, assign) Fog fog;
@end

@implementation frogViewController

- (void)viewDidLoad
{
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1);
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.8, 0.1, 0.2);
    material.specularColor = GLKVector3Make(0, 0, 0);
    material.smoothness = 0;
    self.material = material;
    
    Fog fog;
    fog.fogColor = GLKVector3Make(1, 1, 1);
    fog.fogStart = 0;
    fog.fogEnd = 200;
    fog.fogIndensity = 0.02;
    fog.fogType = FogTypeExpSquare;
    self.fog = fog;
    
    self.useNormalMap = NO;
    
    self.objects = [NSMutableArray new];
    [self createTerrain];
    [self createCubeTexture];
    [self createSkyBox];
}

- (void)createTerrain
{
    //加在shader
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_terrain" ofType:@".glsl"];
    GLContext *terrainContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    GLKTextureInfo *grass = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"grass_01.jpg"].CGImage options:nil error:nil];
    NSError *error;
    GLKTextureInfo *dirt = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"dirt_01.jpg"].CGImage options:nil error:&error];
    glBindTexture(GL_TEXTURE_2D, grass.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glBindTexture(GL_TEXTURE_2D, dirt.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    UIImage *heightMap = [UIImage imageNamed:@"terrain_01.jpg"];
    Terrain *terrain = [[Terrain alloc] initWithGLContext:terrainContext heightMap:heightMap size:CGSizeMake(500, 500) height:100 gress:grass dirt:dirt];
    terrain.modelMatrix = GLKMatrix4MakeTranslation(-250, 0, -250);
    [self.objects addObject:terrain];
}

- (void)createCubeTexture
{
    NSMutableArray *files = [NSMutableArray new];
    for (int i = 0; i < 6; ++i) {
        NSString *filename = [NSString stringWithFormat:@"cube-%d", i + 1];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"tga"];
        [files addObject:filePath];
    }
    NSError *error;
    self.cubeTexture = [GLKTextureLoader cubeMapWithContentsOfFiles:files options:nil error:&error];

}

- (void)createSkyBox
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_skybox" ofType:@".glsl"];
    GLContext *skyGLContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    self.skyBox = [[SkyBox alloc] initWithGLContext:skyGLContext diffuseMap:nil normalMap:nil];
    self.skyBox.modelMatrix = GLKMatrix4MakeScale(1000, 1000, 1000);
}

#pragma mark - Update Delegate
- (void)update
{
    [super update];
    //设置观察位置
    self.eyePosition = GLKVector3Make(5 * sin(self.elapsedTime / 1.5), 20, 5 * cos(self.elapsedTime / 1.5));
    GLKVector3 lookAtPosition = GLKVector3Make(0, 20, 0);
    //设置观察矩阵
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)bindFog:(GLContext *)context
{
    [context setUniform1f:@"fog.fogType" value:self.fog.fogType];
    [context setUniform1f:@"fog.fogStart" value:self.fog.fogStart];
    [context setUniform1f:@"fog.fogEnd" value:self.fog.fogEnd];
    [context setUniform1f:@"fog.fogIndensity" value:self.fog.fogIndensity];
    [context setUniform3fv:@"fog.fogColor" value:self.fog.fogColor];
}

- (void)drawObjects
{
    [self.skyBox.context active];
    [self bindFog:self.skyBox.context];
    [self.skyBox.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [self.skyBox.context setUniformMatrix4fv:@"cameraMatrxi" value:self.cameraMatrix];
    [self.skyBox.context setUniform3fv:@"eyePosition" value:self.eyePosition];
    [self.skyBox.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE4 uniformName:@"envMap"];
    [self.skyBox draw: self.skyBox.context];
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.context active];
        [self bindFog:obj.context];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.light.direction];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
    }];
}
@end
