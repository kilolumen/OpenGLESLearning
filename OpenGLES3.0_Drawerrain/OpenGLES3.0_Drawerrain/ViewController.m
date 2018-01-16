//
//  ViewController.m
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "ViewController.h"
#import "GLTerrain.h"

@interface ViewController ()
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) GLKVector3 lightDirection; // 平行光光照方向

@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);
    
    
    self.objects = [NSMutableArray new];
    [self createTerrain];
}


- (void)createTerrain {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_terrain" ofType:@".glsl"];
    GLContext *terrainContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    GLKTextureInfo *grass = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"grass_01.jpg"].CGImage options:nil error:nil];
    NSError *error;
    GLKTextureInfo *dirt = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"dirt_01.jpg"].CGImage options:nil error:&error];
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, grass.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glBindTexture(GL_TEXTURE_2D, dirt.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    
    UIImage *heightMap = [UIImage imageNamed:@"terrain_01.jpg"];
    GLTerrain *terrain = [[GLTerrain alloc] initWithGLContext:terrainContext heightMap:heightMap size:CGSizeMake(500, 500) height:100 grass:grass dirt:dirt];
    terrain.modelMatrix = GLKMatrix4MakeTranslation(-250, 0, -250);
    [self.objects addObject:terrain];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    GLKVector3 eyePosition = GLKVector3Make(500 * sin(self.elapsedTime / 2.0), sin(self.elapsedTime) * 50 + 250, 500 * cos(self.elapsedTime / 2.0));
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

@end
