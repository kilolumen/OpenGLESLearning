#import "Cube.h"

@interface Cube ()
{
    GLuint vbo;
    GLuint indexVbo;
    GLuint vao;
}
@property (nonatomic, strong) GLKTextureInfo *diffuseTexture;
@property (nonatomic, strong) GLKTextureInfo *normalTexture;
@end

@implementation Cube
- (instancetype)initWithGLContext:(GLContext *)context
{
    self = [super initWithGLContext:context];
    if (self) {
        [self genTexture:[UIImage imageNamed:@"texture.jpg"]];
        self.modelMatrix = GLKMatrix4Identity;
        [self genVBO];
        [self genIndexVBO];
        [self genVAO];
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &vao);
    glDeleteBuffers(1, &vbo);
}

- (GLfloat *)cubeData
{
    static GLfloat cubeData[] = {
        // X轴0.5处的平面
        0.5,  -0.5,    0.5f, 1,  0,  0, 0, 0,   // VertexA
        0.5,  -0.5f,  -0.5f, 1,  0,  0, 0, 1,   // VertexB
        0.5,  0.5f,   -0.5f, 1,  0,  0, 1, 1,   // VertexC
        0.5,  0.5,    -0.5f, 1,  0,  0, 1, 1,   // VertexC
        0.5,  0.5f,    0.5f, 1,  0,  0, 1, 0,   // VertexD
        0.5,  -0.5f,   0.5f, 1,  0,  0, 0, 0,   // VertexA
        // X轴-0.5处的平面
        -0.5,  -0.5,    0.5f, -1,  0,  0, 0, 0, // VertexE
        -0.5,  -0.5f,  -0.5f, -1,  0,  0, 0, 1, // VertexF
        -0.5,  0.5f,   -0.5f, -1,  0,  0, 1, 1, // VertexG
        -0.5,  0.5,    -0.5f, -1,  0,  0, 1, 1, // VertexG
        -0.5,  0.5f,    0.5f, -1,  0,  0, 1, 0, // VertexH
        -0.5,  -0.5f,   0.5f, -1,  0,  0, 0, 0, // VertexE
        
        -0.5,  0.5,  0.5f, 0,  1,  0, 0, 0,     // VertexH
        -0.5f, 0.5, -0.5f, 0,  1,  0, 0, 1,     // VertexG
        0.5f, 0.5,  -0.5f, 0,  1,  0, 1, 1,     // VertexC
        0.5,  0.5,  -0.5f, 0,  1,  0, 1, 1,     // VertexC
        0.5f, 0.5,   0.5f, 0,  1,  0, 1, 0,     // VertexD
        -0.5f, 0.5,  0.5f, 0,  1,  0, 0, 0,     // VertexH
        -0.5, -0.5,   0.5f, 0,  -1,  0, 0, 0,   // VertexE
        -0.5f, -0.5, -0.5f, 0,  -1,  0, 0, 1,   // VertexF
        0.5f, -0.5,  -0.5f, 0,  -1,  0, 1, 1,   // VertexB
        0.5,  -0.5,  -0.5f, 0,  -1,  0, 1, 1,   // VertexB
        0.5f, -0.5,   0.5f, 0,  -1,  0, 1, 0,   // VertexA
        -0.5f, -0.5,  0.5f, 0,  -1,  0, 0, 0,   // VertexE
        
        -0.5,   0.5f,  0.5,   0,  0,  1, 0, 0,  // VertexH
        -0.5f,  -0.5f,  0.5,  0,  0,  1, 0, 1,  // VertexE
        0.5f,   -0.5f,  0.5,  0,  0,  1, 1, 1,  // VertexA
        0.5,    -0.5f, 0.5,   0,  0,  1, 1, 1,  // VertexA
        0.5f,  0.5f,  0.5,    0,  0,  1, 1, 0,  // VertexD
        -0.5f,   0.5f,  0.5,  0,  0,  1, 0, 0,  // VertexH
        -0.5,   0.5f,  -0.5,   0,  0,  -1, 0, 0,    // VertexG
        -0.5f,  -0.5f,  -0.5,  0,  0,  -1, 0, 1,    // VertexF
        0.5f,   -0.5f,  -0.5,  0,  0,  -1, 1, 1,    // VertexB
        0.5,    -0.5f, -0.5,   0,  0,  -1, 1, 1,    // VertexB
        0.5f,  0.5f,  -0.5,    0,  0,  -1, 1, 0,    // VertexC
        -0.5f,   0.5f,  -0.5,  0,  0,  -1, 0, 0,    // VertexG
    };
    
    return cubeData;
}

- (GLfloat *)cubeVertex
{
    static GLfloat cubeData[] = {
        0.5,  -0.5,    0.5f, 0.5773502691896258, -0.5773502691896258, 0.5773502691896258, 0, 0,   // VertexA
        0.5,  -0.5f,  -0.5f, 0.5773502691896258, -0.5773502691896258, -0.5773502691896258, 0, 1,   // VertexB
        0.5,  0.5f,   -0.5f, 0.5773502691896258, 0.5773502691896258, -0.5773502691896258, 1, 1,   // VertexC
        0.5,  0.5f,    0.5f, 0.5773502691896258, 0.5773502691896258, 0.5773502691896258, 1, 0,   // VertexD
        -0.5,  -0.5,    0.5f, -0.5773502691896258, -0.5773502691896258, 0.5773502691896258, 0, 0, // VertexE
        -0.5,  -0.5f,  -0.5f, -0.5773502691896258, -0.5773502691896258, -0.5773502691896258, 0, 1, // VertexF
        -0.5,  0.5f,   -0.5f, -0.5773502691896258, 0.5773502691896258, -0.5773502691896258, 1, 1, // VertexG
        -0.5,  0.5f,    0.5f, -0.5773502691896258, 0.5773502691896258, 0.5773502691896258, 1, 0, // VertexH
    };
    
    return cubeData;
}

- (GLushort *)cubeVertexIndice {
    static GLushort cubeDataIndice[] = {
        0,      // VertexA
        1,      // VertexB
        2,      // VertexC
        2,      // VertexC
        3,      // VertexD
        0,      // VertexA
        4,      // VertexE
        5,      // VertexF
        6,      // VertexG
        6,      // VertexG
        7,      // VertexH
        4,      // VertexE
        
        7,      // VertexH
        6,      // VertexG
        2,      // VertexC
        2,      // VertexC
        3,      // VertexD
        7,      // VertexH
        4,      // VertexE
        5,      // VertexF
        1,      // VertexB
        1,      // VertexB
        0,      // VertexA
        4,      // VertexE
        
        7,      // VertexH
        4,      // VertexE
        0,      // VertexA
        0,      // VertexA
        3,      // VertexD
        7,      // VertexH
        6,      // VertexG
        5,      // VertexF
        1,      // VertexB
        1,      // VertexB
        2,      // VertexC
        6,      // VertexG
    };
    return cubeDataIndice;
}

#pragma mark - Texture
- (void)genTexture:(UIImage *)image
{
    if (image) {
        self.diffuseTexture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:nil];
        self.normalTexture  = self.diffuseTexture;
    }
}

- (void)genVBO
{
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 8 * 8 * sizeof(GLfloat), [self cubeVertex], GL_STATIC_DRAW);
}

- (void)genIndexVBO
{
    glGenBuffers(1, &indexVbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexVbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 36 * sizeof(GLushort), [self cubeVertexIndice], GL_STATIC_DRAW);
}

- (void)genVAO
{
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexVbo);
    [self.context bindGeometryAttribs:NULL];
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glcontext
{
    [glcontext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glcontext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glcontext bindTexture:self.diffuseTexture to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glcontext bindTexture:self.normalTexture  to:GL_TEXTURE1 uniformName:@"normalMap"];
    [glcontext drawTrianglesWithIndicedVAO:vao vertexCount:36];
}
@end
