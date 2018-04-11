//
//  ViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by loyinglin on 16/5/10.
//  Copyright © 2016年 loyinglin. All rights reserved.
//

#import "LYOpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVUtilities.h>
#import <mach/mach_time.h>
#import <GLKit/GLKit.h>
#import "Plane.h"
#import "GLBox.h"
#import "GLCylinder.h"
#import "Cube.h"
#import "GLTerrain.h"
#import "GLCar.h"
#import "GLPlane.h"
#import "PhysicsEngine.h"
#import "GameObject.h"
#import "SKYBox.h"
#import "Billboard.h"
#import "ParticleSystem.h"
#import <CoreMotion/CoreMotion.h>
#import "GLSphere.h"
// Uniform index.

#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+ 1) - (__MIN__)))

typedef struct {
    GLKVector3 position;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
}PointLight;

typedef struct {
    GLKVector3 direction;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
}Directionlight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness;
}Material;

typedef enum : NSUInteger{
    FogTypeLinear = 0,
    FogTypeExp = 1,
    FogTypeExpSquare  = 2,
}FogType;

typedef struct {
    FogType fogType;
    GLfloat fogStart;
    GLfloat fogEnd;
    GLfloat fogIndensity;
    GLKVector3 fogColor;
}Fog;

enum
{
	UNIFORM_Y,
	UNIFORM_UV,
	UNIFORM_COLOR_CONVERSION_MATRIX,
    UNIFORM_RGBA,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];
// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
static const GLfloat kColorConversion601[] = {
		1.164,  1.164, 1.164,
		  0.0, -0.392, 2.017,
		1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
		1.164,  1.164, 1.164,
		  0.0, -0.213, 2.112,
		1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};



@interface LYOpenGLView ()
{
	// The pixel dimensions of the CAEAGLLayer.
	GLint _backingWidth;
	GLint _backingHeight;

	EAGLContext *_context;
	CVOpenGLESTextureRef _lumaTexture;
	CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureRef _rgbaTexture;
	CVOpenGLESTextureCacheRef _videoTextureCache;
	
	GLuint _frameBufferHandle;
	GLuint _colorBufferHandle;
    GLuint _depthBufferHandle;
	
    GLfloat *_preferredConversion;
    
    GLuint _textrueY;
    GLuint _textureUV;
    GLKMatrix3 _matrix3;
    
    
    //shadow
    GLuint shadowMapFrameBuffer;
    GLuint shadowDepthMap;
    
    
    BOOL _bStart;
     CMQuaternion _rotationRate;
}

@property GLuint program;
@property GLuint rgbaProgram;
@property (nonatomic, strong) NSMutableArray<GLPlane *> *planes;
@property (nonatomic, strong) NSMutableArray<GLObject *> *objects;
@property (nonatomic, strong) Plane *previewPlane;
@property (nonatomic, strong) GLBox *box;
@property (nonatomic, strong) Cube *cube;
@property (nonatomic, strong) NSMutableArray <Cube *> *cubes;
@property (nonatomic, strong) GLCylinder *cylinder;
@property (nonatomic, strong) GLTerrain *terrain;
@property (nonatomic, strong) GLCar *car;
@property (nonatomic, strong) GLBox *floor;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, assign) GLKMatrix4 cameraMatrix;
@property (nonatomic, assign) PointLight light;
@property (nonatomic, assign) Directionlight directionLight;
@property (nonatomic, assign) Material material;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) CGSize frameBufferSize;
@property (nonatomic, assign) GLKMatrix4 planeProjectionMatrix;
@property (nonatomic, assign) BOOL useNormalMap;

//skyBox
@property (nonatomic, strong) SKYBox *skyBox;//天空盒
@property (nonatomic, strong) GLKTextureInfo *cubeTexture;
@property (nonatomic, assign) Fog fog;

@property (strong, nonatomic) GLContext *treeGlContext;

//plane
@property (nonatomic, strong) GLPlane *plane;

//texture Projection
@property (nonatomic, assign) GLKMatrix4 projectorMatrix;
@property (nonatomic, strong) GLKTextureInfo *projectorMap;
@property (nonatomic, assign) BOOL useProjector;

//投影器矩阵
@property (nonatomic, assign) GLKMatrix4 lightProjectinoMatrix;
@property (nonatomic, assign) GLKMatrix4 lightCameraMatrix;
@property (nonatomic, assign) CGSize shadowMapSize;
@property (nonatomic, assign) GLContext *shadowMapContext;

@property (nonatomic, strong) NSMutableArray <GameObject *> *gameObjects;
@property (nonatomic, strong) PhysicsEngine *physicsEngine;

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (nonatomic, assign) float elapsedTime;

@property (nonatomic, strong) GLSphere *sphere;


- (void)setupBuffers;
- (void)cleanUpTextures;

@end

@implementation LYOpenGLView

+ (Class)layerClass
{
	return [CAEAGLLayer class];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		self.contentScaleFactor = [[UIScreen mainScreen] scale];

		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

		eaglLayer.opaque = TRUE;
		eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
										  kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};

		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

		if (!_context || ![EAGLContext setCurrentContext:_context]) {
			return nil;
		}
		
		_preferredConversion = kColorConversion709;
        _elapsedTime = 0.0;
        
        _objects = [NSMutableArray array];
        
        self.useNormalMap = NO;
        
//        [self createTerrain];
        [self createSkyBox];
        [self createTrees];
        
//        [self createParticles];
        
        
        
        //add a button
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 20, 50, 50)];
        [self addSubview:btn];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"开始" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(begin:) forControlEvents:UIControlEventTouchUpInside];
        _bStart = YES;
	}
	return self;
}

-(void)stopMotionManager{
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)begin:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self startMotionManager];
        _bStart = YES;
        [btn setTitle:@"stop" forState:UIControlStateNormal];
    }else{
        [self stopMotionManager];
        _bStart = NO;
        [btn setTitle:@"begin" forState:UIControlStateNormal];
    }
}

- (void)createPlaneTexture:(GLuint)textureY textureUV:(GLuint)textureUV matrix3:(GLfloat *)matrix3
{
    [EAGLContext setCurrentContext:_context];
    
    NSString *vertexStr = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragmentStr = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    
    GLContext *planeContext = [GLContext contextWithVertexShaderPath:vertexStr fragmentShaderPath:fragmentStr];
    
    self.previewPlane = [[Plane alloc] initWithGLContext:planeContext textureY:textureY textureUV:textureUV matrix:matrix3];
}

# pragma mark - OpenGL setup
- (void)setupGL
{
	[EAGLContext setCurrentContext:_context];
	[self setupBuffers];
	
	// Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
	if (!_videoTextureCache) {
		CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
		if (err != noErr) {
			NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
			return;
		}
	}
    
    [self setupMatrixs];
}

- (void)setupMatrixs
{
    // 使用透视投影矩阵
    float aspect = self.frame.size.width / self.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.1, 10000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
}
- (PointLight)setupLight
{
    PointLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.position = GLKVector3Make(30, 100, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    return defaultLight;
}

- (Directionlight)setupDirectionLight
{
    Directionlight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1);
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    return defaultLight;
}

- (Material)setupMaterial
{
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.8, 0.1, 0.2);
    material.specularColor = GLKVector3Make(0, 0, 0);
    material.smoothness = 0;
    return material;
}

- (GLBox *)createBoxWith:(GLKMatrix4)modelMatrix
{
    self.light = [self setupLight];
    self.material = [self setupMaterial];
    self.useNormalMap = YES;
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex2" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment2" ofType:@".glsl"];
    
   GLContext *boxContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    GLBox * box = [GLBox objWithGLContext:boxContext objFile:objFilePath diffuseMap:diffuseMap normalMap:normalMap];
    box.modelMatrix = modelMatrix;
    return box;
}

- (void)createCylinder
{
    GLKTextureInfo *metal1 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_01.png"].CGImage options:nil error:nil];
    GLKTextureInfo *metal2 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_02.jpg"].CGImage options:nil error:nil];
    GLKTextureInfo *metal3 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_03.png"].CGImage options:nil error:nil];
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"cylinder" ofType:@"vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"cylinder" ofType:@"fsh"];
    
    GLContext *cylinderContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    // 四边的圆柱体就是一个正方体
    GLCylinder * cylinder3 = [[GLCylinder alloc] initWithGLContext:cylinderContext sides:4 radius:0.41 height:0.3 texture:metal2];
    cylinder3.modelMatrix = GLKMatrix4MakeTranslation(0, -2.0, 0);
    [self.objects addObject:cylinder3];
    
    GLCylinder * cylinder2 = [[GLCylinder alloc] initWithGLContext:cylinderContext sides:16 radius:0.2 height:4.0 texture:metal3];
    [self.objects addObject:cylinder2];
    
    //4边的圆柱体就是一个正方体
    GLCylinder * cylinder1 = [[GLCylinder alloc] initWithGLContext:cylinderContext sides:4 radius:0.9 height:1.2 texture:metal1];
    cylinder1.modelMatrix = GLKMatrix4MakeTranslation(0, 2.0, 0);
    [self.objects addObject:cylinder1];
}

#pragma mark - Utilities

- (void)setupBuffers
{
	glEnable(GL_DEPTH_TEST);
	
	glGenFramebuffers(1, &_frameBufferHandle);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
	
	glGenRenderbuffers(1, &_colorBufferHandle);
	glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
	
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    
    glGenRenderbuffers(1, &_depthBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBufferHandle);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBufferHandle);
    
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
	}
}

- (void)cleanUpTextures
{
	if (_lumaTexture) {
		CFRelease(_lumaTexture);
		_lumaTexture = NULL;
	}
	
	if (_chromaTexture) {
		CFRelease(_chromaTexture);
		_chromaTexture = NULL;
	}
	// Periodic texture cache flush every frame
	CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)dealloc
{
	[self cleanUpTextures];
	
	if(_videoTextureCache) {
		CFRelease(_videoTextureCache);
	}
}

#pragma mark - OpenGLES drawing

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
           rbgaPixelBuffer:(CVPixelBufferRef)rgbaPixel
                     array:(NSArray *)points
{
	CVReturn err;
    
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context]; // 非常重要的一行代码
    }
    
    [self cleanUpTextures];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    // Set the view port to the entire view.
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	if (pixelBuffer != NULL) {
		int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
		int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
		
		if (!_videoTextureCache) {
			NSLog(@"No video texture cache");
			return;
		}
		
		/*
		 Use the color attachment of the pixel buffer to determine the appropriate color conversion matrix.
		 */
		CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
		
		if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
            if (self.isFullYUVRange) {
                _preferredConversion = kColorConversion601FullRange;
            }
            else {
                _preferredConversion = kColorConversion601;
            }
		}
		else {
			_preferredConversion = kColorConversion709;
		}
		
		/*
         CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture optimally from CVPixelBufferRef.
         */
		
		/*
         Create Y and UV textures from the pixel buffer. These textures will be drawn on the frame buffer Y-plane.
         */
		glActiveTexture(GL_TEXTURE0);
		err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
														   _videoTextureCache,
														   pixelBuffer,
														   NULL,
														   GL_TEXTURE_2D,
														   GL_LUMINANCE,
														   frameWidth,
														   frameHeight,
														   GL_LUMINANCE,
														   GL_UNSIGNED_BYTE,
														   0,
														   &_lumaTexture);
		if (err) {
			NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
		}
		
        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		// UV-plane.
		glActiveTexture(GL_TEXTURE1);
		err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
														   _videoTextureCache,
														   pixelBuffer,
														   NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE_ALPHA,
                                                           frameWidth / 2,
                                                           frameHeight / 2,
                                                           GL_LUMINANCE_ALPHA,
														   GL_UNSIGNED_BYTE,
														   1,
														   &_chromaTexture);
		if (err) {
			NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
		}
		
		glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}
    
    if (rgbaPixel != NULL) {
        
        int frameWidth = (int)CVPixelBufferGetWidth(rgbaPixel);
        int frameHeight = (int)CVPixelBufferGetHeight(rgbaPixel);
        
        if (!_videoTextureCache) {
            NSLog(@"No video texture cache");
            return;
        }
        
        glActiveTexture(GL_TEXTURE2);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           rgbaPixel,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE,
                                                           frameWidth,
                                                           frameHeight,
                                                           GL_LUMINANCE,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &_rgbaTexture);
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_rgbaTexture), CVOpenGLESTextureGetName(_rgbaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    _elapsedTime += 0.01;
    
    [self update];
    
    glDepthMask(GL_FALSE);
    [self drawPreviewPlane];
    glDepthMask(GL_TRUE);
//    [self drawBox];
//    [self drawCylinder];
//    [self drawCube];
//    [self drawCar];
//    [self drawObjects];
//    [self drawPlane];
    [self drawSkyBox];
//    [self drawTerrain];
    [self drawTrees];
//    [self drawGameObjext];
    
//    [self drawParticles];
	glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    if ([EAGLContext currentContext] == _context) {
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

-(void)startMotionManager{
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    self.motionManager.gyroUpdateInterval = 1.0f / 60;
    self.motionManager.showsDeviceMovementDisplay = YES;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];    [self.motionManager startGyroUpdatesToQueue: [[NSOperationQueue alloc]init] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            
            [self calculateModelViewProjectMatrixWithDeviceMotion:self.motionManager.deviceMotion];
    }];
}

-(void)calculateModelViewProjectMatrixWithDeviceMotion:(CMDeviceMotion*)deviceMotion{
    if (deviceMotion != nil) {
        _rotationRate = deviceMotion.attitude.quaternion;    }
}

- (void)drawPreviewPlane
{
    if (!_previewPlane) {
        
        [self createPlaneTexture:CVOpenGLESTextureGetName(_lumaTexture) textureUV:CVOpenGLESTextureGetName(_chromaTexture) matrix3:_preferredConversion];
    }
    [_previewPlane.context active];
    [_previewPlane draw:_previewPlane.context];
}
- (void)drawBox
{
    if (!_box) {
        
       self.box = [self createBoxWith:GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0)];
    }
    static float elapsedTime = 0.0;
    elapsedTime += 0.1;
    self.eyePosition = GLKVector3Make(0, 2, 6);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    self.box.modelMatrix = GLKMatrix4MakeRotation(M_PI / 2.0 * elapsedTime / 4.0, 0, 1, 0);
    [self.box.context active];
    [self.box.context setUniform1f:@"elapsedTime" value:(GLfloat)elapsedTime];
    [self.box.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [self.box.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
    [self.box.context setUniform3fv:@"eyePosition" value:self.eyePosition];
    [self.box.context setUniform3fv:@"light.position" value:self.light.position];
    [self.box.context setUniform3fv:@"light.color" value:self.light.color];
    [self.box.context setUniform1f:@"light.indensity" value:self.light.indensity];
    [self.box.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
    [self.box.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
    [self.box.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
    [self.box.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
    [self.box.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
    [self.box.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
    [self.box draw:self.box.context];
}

- (void)drawCylinder
{
    
    if (!_objects) {
        self.objects = [NSMutableArray array];
        [self createCylinder];
    }
    
    static float elapsedTime = 0.0;
    elapsedTime += 0.05;
    // 设置平行光方向
    GLKVector3 lightDirection = GLKVector3Make(1, -1, 0);
    GLKVector3 eyePosition = GLKVector3Make(4 * sin(elapsedTime), 4 * sin(elapsedTime), 4 * cos(elapsedTime));
    // 使用透视投影矩阵
    float aspect = self.frame.size.width / self.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, 0, 0, 0, 0, 1, 0);
   [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"lightDirection" value:lightDirection];
        [obj draw:obj.context];
    }];
}

- (void)createCube
{
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@".fsh"];
    GLContext *cubeContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.cubes = [NSMutableArray array];
    
    for(int j = -4; j <= 4; j++){
        for(int i = -4; i <= 4; i++){
            Cube *cube = [[Cube alloc] initWithGLContext:cubeContext];
            cube.modelMatrix = GLKMatrix4MakeTranslation(j * 2, 0, i * 2);
            [self.cubes addObject:cube];
        }
    }
}

- (void)drawCube
{
    if (!_cubes) {
        
        [self createCube];
    }
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 3,//观察位置
                                             0, 0, 0,//看向原点
                                             0, 1, 0);//摄像机方向
    
    // 设置平行光方向
    GLKVector3 lightDirection = GLKVector3Make(1, -1, 0);
    
    static float elapsedTime = 0.0;
    elapsedTime += 0.05;
    GLKVector3 eyePosition = GLKVector3Make(2 * sin(elapsedTime), 2, 2 * cos(elapsedTime));
    self.cameraMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, 0, 0, 0, 0, 1, 0);
    [self.cubes enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        
        [obj.context setUniform3fv:@"lightDirection" value:lightDirection];
        [obj draw:obj.context];
    }];
}
- (void)createTerrain
{
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"terrain" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fog_terrain" ofType:@".fsh"];
    GLContext *terrainContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    UIImage *grassImage = [UIImage imageNamed:@"grass_01.jpg"];
    GLKTextureInfo *grass = [GLKTextureLoader textureWithCGImage:grassImage.CGImage options:nil error:nil];
    
    UIImage *dirtImage = [UIImage imageNamed:@"dirt_01.jpg"];
    GLKTextureInfo *dirt = [GLKTextureLoader textureWithCGImage:dirtImage.CGImage options:nil error:nil];
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, grass.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glBindTexture(GL_TEXTURE_2D, dirt.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    
    UIImage *heightMap = [UIImage imageNamed:@"terrain_01.jpg"];
    _terrain = [[GLTerrain alloc] initWithGLContext:terrainContext heightMap:heightMap size:CGSizeMake(500, 500) height:100 grass:grass dirt:dirt];
    _terrain.modelMatrix = GLKMatrix4MakeTranslation(-250, 0, -250);
}

- (void)drawTerrain
{
    [_terrain.context active];
    [self bindFog:_terrain.context];
    [_terrain.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
    [_terrain.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [_terrain.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
    [_terrain.context setUniform3fv:@"eyePosition" value:self.eyePosition];
    [_terrain.context setUniform3fv:@"light.direction" value:self.directionLight.direction];
    [_terrain.context setUniform3fv:@"light.color" value:self.directionLight.color];
    [_terrain.context setUniform1f:@"light.indensity" value:self.directionLight.indensity];
    [_terrain.context setUniform1f:@"light.ambientIndensity" value:self.directionLight.ambientIndensity];
    [_terrain.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
    [_terrain.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
    [_terrain.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
    [_terrain.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
    [_terrain.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
    [_terrain.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE4 uniformName:@"envMap"];
    [_terrain draw:_terrain.context];
}

- (void)createGLCar
{
    self.directionLight = [self setupDirectionLight];
    self.material = [self setupMaterial];
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"obj"];
    NSString *vertex = [[NSBundle mainBundle] pathForResource:@"car" ofType:@".vsh"];
    NSString *fragment = [[NSBundle mainBundle] pathForResource:@"car" ofType:@".fsh"];
    GLContext *carContext = [GLContext contextWithVertexShaderPath:vertex fragmentShaderPath:fragment];
    self.car = [[GLCar alloc] initWithGLContext:carContext objFile:objFilePath];
    self.car.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
}

- (void)drawCar
{
    if (!_car) {
        [self createGLCar];
    }
    
    static float elapsedTime = 0.0;
    elapsedTime += 0.05;
    
    self.eyePosition = GLKVector3Make(60, 100, 200);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    self.car.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0 * elapsedTime / 4.0, 0, 1, 0);
    
    [_car.context active];
    [_car.context setUniform1f:@"elapsedTime" value:(GLfloat)elapsedTime];
    [_car.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [_car.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
    [_car.context setUniform3fv:@"eyePosition" value:self.eyePosition];
    [_car.context setUniform3fv:@"direcionLight.direction" value:self.directionLight.direction];
    [_car.context setUniform3fv:@"direcionLight.color" value:self.directionLight.color];
    [_car.context setUniform1f:@"direcionLight.indensity" value:self.directionLight.indensity];
    [_car.context setUniform1f:@"direcionLight.ambientIndensity" value:self.directionLight.ambientIndensity];
    [_car.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
    [_car.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
    [_car.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
    [_car.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
    [_car draw:_car.context];
}

- (GLBox *)createFloor
{
    UIImage *normalImage = [UIImage imageNamed:@"stoneFloor_NRM.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"stoneFloor.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex2" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment2" ofType:@".glsl"];
    
    GLContext *boxContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    GLBox *box = [GLBox objWithGLContext:boxContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    
    box.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, -0.1, 0), GLKMatrix4MakeScale(3, 0.2, 3 ));
    return box;
}

- (void)setupTextureProjector
{
    self.directionLight = [self setupDirectionLight];
    self.material = [self setupMaterial];
    
    self.useNormalMap = YES;
    self.objects = [NSMutableArray array];
    [self.objects addObject:[self createBoxWith:GLKMatrix4MakeTranslation(-1, 0.5, -1.3)]];
    [self.objects addObject:[self createBoxWith:GLKMatrix4MakeTranslation(1, 0.2, 1)]];
    [self.objects addObject:[self createFloor]];
    
    GLKMatrix4 projectorProjectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -100, 100);
    GLKMatrix4 projectorCameraMatrix = GLKMatrix4MakeLookAt(0.4, 4, 0, 0, 0, 0, 0, 1, 0);
    self.projectorMatrix = GLKMatrix4Multiply(projectorProjectionMatrix, projectorCameraMatrix);
    UIImage *projectorImage = [UIImage imageNamed:@"squarepants.jpg"];
    self.projectorMap = [GLKTextureLoader textureWithCGImage:projectorImage.CGImage options:nil error:nil];
    self.useProjector = YES;
    
    
    //shadow
    self.lightProjectinoMatrix = GLKMatrix4MakeOrtho(-10, 10, -10, 10, -100, 100);//正交矩阵就是一个映射关系
    self.lightCameraMatrix = GLKMatrix4MakeLookAt(-self.directionLight.direction.x * 10, -self.directionLight.direction.y * 10, -self.directionLight.direction.z * 10, 0, 0, 0, 0, 1, 0);
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"shadow" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"shadow" ofType:@".fsh"];
    self.shadowMapContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    [self createShadowMap];
}

- (void)createShadowMap
{
    self.shadowMapSize = CGSizeMake(1024, 1024);
    glGenFramebuffers(1, &shadowMapFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFrameBuffer);
    
    //生成深度缓存区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &shadowDepthMap);
    glBindTexture(GL_TEXTURE_2D, shadowDepthMap);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, self.shadowMapSize.width, self.shadowMapSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_COMPONENT, GL_TEXTURE_2D, shadowDepthMap, 0);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        // framebuffer生成失败
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)drawObjects
{
    if (!_objects) {
        
        [self setupTextureProjector];
    }
    static float elapsedTime = 0.0;
    elapsedTime += 0.01;
    self.eyePosition = GLKVector3Make(1, 4, 4);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    // update projector matrix
    GLKMatrix4 projectorProjectionMatrix = GLKMatrix4MakeOrtho(-2, 2, -2, 2, -100, 100);
    GLKMatrix4 projectorCameraMatrix = GLKMatrix4MakeLookAt(0, 4, 0, 0, 0, 0, cos(elapsedTime), 0, sin(elapsedTime));
    self.projectorMatrix = GLKMatrix4Multiply(projectorProjectionMatrix, projectorCameraMatrix);
    
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"direcionLight.direction" value:self.directionLight.direction];
        [obj.context setUniform3fv:@"direcionLight.color" value:self.directionLight.color];
        [obj.context setUniform1f:@"direcionLight.indensity" value:self.directionLight.indensity];
        [obj.context setUniform1f:@"direcionLight.ambientIndensity" value:self.directionLight.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        [obj.context setUniformMatrix4fv:@"projectorMatrix" value: self.projectorMatrix];
        [obj.context bindTexture:self.projectorMap to:GL_TEXTURE2 uniformName:@"projectorMap"];
        [obj.context setUniform1i:@"useProjector" value:self.useProjector];
        
        [obj draw:obj.context];
    }];
}

- (void)createPlane
{
    self.planes = [NSMutableArray new];
    // 使用正交投影矩阵
    self.projectionMatrix = GLKMatrix4MakeOrtho(-self.frame.size.width / 2, self.frame.size.width / 2, -self.frame.size.height / 2, self.frame.size.height, -10, 10);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 1, 0, 0, 0, 0, 1, 0);
    
    UIImage *diffuseImage = [UIImage imageNamed:@"plane2.png"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex2" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"plane" ofType:@".fsh"];
    GLContext *planeContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    for (int i = 0; i < 4; ++i) {
        GLPlane * plane = [[GLPlane alloc] initWithGLContext:planeContext texture:diffuseMap.name];
        int x = RANDOM_INT(0, (int)self.frame.size.width) - self.frame.size.width / 2;
        int y = self.frame.size.height / 2;
        plane.modelMatrix = GLKMatrix4Translate(plane.modelMatrix, x, -y + 50, 0);
        plane.modelMatrix = GLKMatrix4Scale(plane.modelMatrix, 100, 100, 0);
        [self.planes addObject:plane];
    }
}

- (void)drawPlane
{
    if (!_planes) {
        
        [self createPlane];
    }
    static float elapsedTime = 0.0;
    elapsedTime += 0.01;
    
    [self.planes enumerateObjectsUsingBlock:^(GLPlane * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.modelMatrix = GLKMatrix4Translate(obj.modelMatrix, 0, [self getRandomNumber:0 to:1000] / 100000.0, 0.0);
        [obj.context active];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj draw:obj.context];
    }];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (void)drawGameObjext{
    
    if (!_gameObjects) {
        self.directionLight = [self setupDirectionLight];
        self.material = [self setupMaterial];
        self.useNormalMap = YES;
        _gameObjects = [NSMutableArray new];
        _physicsEngine = [PhysicsEngine new];
        [self createPhysicsCube: GLKVector3Make(8, 0.2, 8) mass:0.0 position:GLKVector3Make(0, 0, 0)];
        [self createPhysicsCube: GLKVector3Make(0.5, 0.5, 0.5) mass:1.0 position:GLKVector3Make(0, 5, 0)];
    }
    static float timeSinceLastUpdate = 0.0;
    timeSinceLastUpdate += 1.0;
    
    [self.physicsEngine update:timeSinceLastUpdate];
    self.eyePosition = GLKVector3Make(1, 2, 6);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    static float elapsedTime = 0.0;
    elapsedTime += 0.1;
    [self.gameObjects enumerateObjectsUsingBlock:^(GameObject *gameObj, NSUInteger idx, BOOL *stop) {
        GLObject *obj = gameObj.geometry;
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.directionLight.direction];
        [obj.context setUniform3fv:@"light.color" value:self.directionLight.color];
        [obj.context setUniform1f:@"light.indensity" value:self.directionLight.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.directionLight.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        [obj draw:obj.context];
    }];
    
    GLfloat center = ((float)(arc4random() % 50)/(float)50) * 2 - 1;
    NSLog(@"sunjian center is %.2f", center);
}

- (void)createPhysicsCube:(GLKVector3)size mass:(float)mass position:(GLKVector3)position
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"game" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"game" ofType:@".fsh"];
    GLContext *gameContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    Cube *cube = [[Cube alloc] initWithGLContext:gameContext];
    cube.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x, position.y, position.z), GLKMatrix4MakeScale(size.x, size.y, size.z));
    
    RigidBody *rigidBody = [[RigidBody alloc] initAsBox:size];
    rigidBody.mass = mass;
    GameObject *gameObject = [[GameObject alloc] initWithGeometry:cube rigidBody:rigidBody];
    
    [self.physicsEngine addRigidBody:rigidBody];
    [self.gameObjects addObject:gameObject];
}

- (void)createCubeTexture
{
    NSMutableArray *files = [NSMutableArray new];
    for(int i = 0; i < 6; ++i){
        NSString *fileName = [NSString stringWithFormat:@"cube-%d", i + 1];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        [files addObject:filePath];
    }
    self.cubeTexture = [GLKTextureLoader cubeMapWithContentsOfFiles:files options:nil error:nil];
}

- (void)setupFog
{
    Fog fog;
    fog.fogColor = GLKVector3Make(1, 1, 1);
    fog.fogStart = 0;
    fog.fogEnd = 200;
    fog.fogIndensity = 0.02;
    fog.fogType = FogTypeExpSquare;
    self.fog = fog;
}

- (void)createSkyBox
{
    
    [self setupMatrixs];
    self.directionLight = [self setupDirectionLight];
    self.material = [self setupMaterial];
    [self setupFog];
    [self createCubeTexture];
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"skyBox" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"skyBox" ofType:@".fsh"];
    GLContext *skyGlContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.skyBox = [[SKYBox alloc] initWithGLContext:skyGlContext];
    self.skyBox.modelMatrix = GLKMatrix4MakeScale(10000, 10000, 10000);
}

- (void)bindFog:(GLContext *)context
{
    [context setUniform1i:@"fog.fotType" value:self.fog.fogType];
    [context setUniform1i:@"fog.fogStart" value:self.fog.fogStart];
    [context setUniform1i:@"fog.fogEnd" value:self.fog.fogEnd];
    [context setUniform1i:@"fog.fogIndensity" value:self.fog.fogIndensity];
    [context setUniform3fv:@"fog.fogColor" value:self.fog.fogColor];
}

- (void)update
{
    self.eyePosition = GLKVector3Make(0, 0, 0);
    
    if (!_bStart) {
        
        self.lookAtPosition = GLKVector3Make(5* sin(self.elapsedTime / 1.5), 13, 5 * cos(self.elapsedTime /  1.5));
    }else{
        
        self.lookAtPosition = GLKVector3Make(_rotationRate.x, _rotationRate.y, _rotationRate.z);
    }
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, _lookAtPosition.x, _lookAtPosition.y, _lookAtPosition.z, 0, 1, 0);

    static float timeSinceLastUpdate = 0.01;
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:timeSinceLastUpdate];
    }];
}
- (void)drawSkyBox
{
    [self.skyBox.context active];
    [self bindFog:self.skyBox.context];
    [self.skyBox.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [self.skyBox.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
    [self.skyBox.context setUniform3fv:@"eyePosition" value:self.eyePosition];
    [self.skyBox.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE4 uniformName:@"envMap"];
    [self.skyBox draw: self.skyBox.context];
}

- (void)createTrees
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"billboard" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"billboard" ofType:@".fsh"];
    self.treeGlContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    for(int cycleTime = 0; cycleTime < 8; ++cycleTime) {
        for(int angleSampleCount = 0; angleSampleCount < 9; ++angleSampleCount) {
            float angle = rand() / (float)RAND_MAX * M_PI * 2.0;
            float radius = rand() / (float)RAND_MAX * 70 + 40;
            float xloc = cos(angle) * radius;
            float zloc = sin(angle) * radius;
            float y = rand() / (float)RAND_MAX * 100;
            [self createTree:GLKVector3Make(xloc, y, zloc)];
        }
    }
}

- (void)createTree:(GLKVector3)position
{
    GLKTextureInfo *grass = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"tree.png"].CGImage options:nil error:nil];
    Billboard *tree = [[Billboard alloc] initWithGLContext:self.treeGlContext texture:grass];
    [tree setBillboardCenterPosition:position];
    [tree setBillboardSize:GLKVector2Make(6.0, 10.0)];
    [tree setLockToYAxis:YES];
    [self.objects addObject:tree];
}

- (void)drawTrees
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [self bindFog:obj.context];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.directionLight.direction];
        [obj.context setUniform3fv:@"light.color" value:self.directionLight.color];
        [obj.context setUniform1f:@"light.indensity" value:self.directionLight.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.directionLight.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        [obj.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE4 uniformName:@"envMap"];
        
        [obj draw:obj.context];
    }];
}

- (void)createParticles
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"billboard" ofType:@".vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"particle" ofType:@".fsh"];
    GLContext *particleContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    ParticleSystemConfig config;
    config.birthRate = 0.3;
    config.emissionBoxExtends = GLKVector3Make(0.6,0.6,0.6);
    config.emissionBoxTransform = GLKMatrix4MakeTranslation(0, -4, 0);
    config.startLife = 1;
    config.endLife = 2;
    config.startSpeed = GLKVector3Make(-1.6, 12.5, -1.6);
    config.endSpeed = GLKVector3Make(1.6, 12.5, 1.6);
    config.startSize = 1.9;
    config.endSize = 2.6;
    config.startColor = GLKVector3Make(0, 0, 0);
    config.endColor = GLKVector3Make(0.6, 0.5, 0.6);
    config.maxParticles = 600;
    
    GLKTextureInfo *qrcode = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"particle.png"].CGImage options:nil error:nil];
    
    ParticleSystem *particleSystem = [[ParticleSystem alloc] initWithGLContext:particleContext config:config particleTexture:qrcode];
    [self.objects addObject:particleSystem];
}

- (void)drawParticles
{
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [self bindFog:obj.context];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.directionLight.direction];
        [obj.context setUniform3fv:@"light.color" value:self.directionLight.color];
        [obj.context setUniform1f:@"light.indensity" value:self.directionLight.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.directionLight.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        [obj.context bindCubeTexture:self.cubeTexture to:GL_TEXTURE4 uniformName:@"envMap"];
        
        [obj draw:obj.context];
    }];
}
#pragma mark - Touch Event
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self createPhysicsCube: GLKVector3Make(0.5, 0.5, 0.5) mass:1.0 position:GLKVector3Make(0, 4, 0)];
}
@end

