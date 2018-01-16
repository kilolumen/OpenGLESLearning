//
//  WaveFrontOBJ.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "WaveFrontOBJ.h"
@interface WaveFrontOBJ ()
{
    GLuint vertexVBO;
    GLuint vertexIBO;
    
    GLuint vao;
}
@property (nonatomic, strong) NSMutableData *positionData;
@property (nonatomic, strong) NSMutableData *normalData;
@property (nonatomic, strong) NSMutableData *uvData;
@property (nonatomic, strong) NSMutableData *positionIndexData;
@property (nonatomic, strong) NSMutableData *normalIndexData;
@property (nonatomic, strong) NSMutableData *uvIndexData;
@property (nonatomic, strong) NSMutableData *vertexData;
@end


@implementation WaveFrontOBJ

- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath
{
    self = [super initWithGLContext:context];
    if (self) {
        self.positionData = [NSMutableData data];
        self.normalData = [NSMutableData data];
        self.uvData = [NSMutableData data];
        self.positionIndexData = [NSMutableData data];
        self.normalIndexData = [NSMutableData data];
        self.uvIndexData = [NSMutableData data];
        self.vertexData = [NSMutableData data];
        
        [self loadDataFromObj:filePath];
        [self decompressToVertexArray];
        [self genBufferObjects];
        [self genVAO];
        
        return self;
    }
    
    return nil;
}

- (void)genBufferObjects
{
    glGenBuffers(1, &vertexVBO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, self.vertexData.length, self.vertexData.bytes, GL_STATIC_DRAW);
}

- (void)genVAO
{
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    [self.context bindAttribs:NULL];
    glBindVertexArrayOES(0);
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
    NSInteger vertexCount = self.positionIndexData.length/sizeof(GLuint);
    [self.context drawTrianglesWithVAO:vao vertexCount:(GLuint)vertexCount];
}

- (void)decompressToVertexArray
{
    NSInteger vertexCount = self.positionIndexData.length / sizeof(GLuint);
    for (int i = 0; i < vertexCount; ++i) {
        int positionIndex = 0;
        [self.positionIndexData getBytes:&positionIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
        [self.vertexData appendBytes:(void *)((char *)self.positionData.bytes + positionIndex * 3 * sizeof(GLfloat)) length: 3 * sizeof(GLfloat)];
        
        int normalIndex = 0;
        [self.normalIndexData getBytes:&normalIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
        [self.vertexData appendBytes:(void *)((char *)self.normalData.bytes + normalIndex * 3 * sizeof(GLfloat)) length: 3 * sizeof(GLfloat)];
        
        int uvIndex = 0;
        [self.uvIndexData getBytes:&uvIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
        [self.vertexData appendBytes:(void *)((char *)self.uvData.bytes + uvIndex * 2 * sizeof(GLfloat)) length: 2 * sizeof(GLfloat)];
    }
}

#pragma mark - 从OBJ文件中读取数据
- (void)loadDataFromObj:(NSString *)filePath
{
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *lines = [fileContent componentsSeparatedByString:@"\n"];
    for(NSString *line in lines){
        if (line.length >= 2) {
            if ([line characterAtIndex:0] == 'v' &&
                [line characterAtIndex:1] == ' ') {
                [self precessVertexLine:line];
            }else if ([line characterAtIndex:0] == 'v' &&
                      [line characterAtIndex:1] == 'n'){
                [self processNormalLine:line];
            }else if ([line characterAtIndex:0] == 'v' &&
                      [line characterAtIndex:1] == 't'){
                [self processUVline:line];
            }else if ([line characterAtIndex:0] == 'f' &&
                      [line characterAtIndex:1] == ' '){
                [self processFaceIndexLine:line];
            }
        }
    }
}

- (void)precessVertexLine:(NSString *)line
{
    static NSString *pattern = @"v\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.positionData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}

- (void)processNormalLine:(NSString *)line
{
    static NSString *pattern = @"vn\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.normalData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}

- (void)processUVline:(NSString *)line
{
    static NSString *pattern = @"vt\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 3) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            [self.uvData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.uvData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
        }
    }
}

- (void)processFaceIndexLine:(NSString *)line
{
    static NSString *pattern = @"f\\s*([0-9]*)/([0-9]*)/([0-9]*)\\s*([0-9]*)/([0-9]*)/([0-9]*)\\s*([0-9]*)/([0-9]*)/([0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 10) {
            // f 顶点/UV/法线 顶点/UV/法线 顶点/UV/法线
            GLuint vertexIndex1 = [[line substringWithRange: [result rangeAtIndex:1]] intValue] - 1;
            GLuint vertexIndex2 = [[line substringWithRange: [result rangeAtIndex:4]] intValue] - 1;
            GLuint vertexIndex3 = [[line substringWithRange: [result rangeAtIndex:7]] intValue] - 1;
            [self.positionIndexData appendBytes:(void *)(&vertexIndex1) length:sizeof(GLuint)];
            [self.positionIndexData appendBytes:(void *)(&vertexIndex2) length:sizeof(GLuint)];
            [self.positionIndexData appendBytes:(void *)(&vertexIndex3) length:sizeof(GLuint)];
            
            GLuint uvIndex1 = [[line substringWithRange: [result rangeAtIndex:2]] intValue] - 1;
            GLuint uvIndex2 = [[line substringWithRange: [result rangeAtIndex:5]] intValue] - 1;
            GLuint uvIndex3 = [[line substringWithRange: [result rangeAtIndex:8]] intValue] - 1;
            [self.uvIndexData appendBytes:(void *)(&uvIndex1) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex2) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex3) length:sizeof(GLuint)];
            
            GLuint normalIndex1 = [[line substringWithRange: [result rangeAtIndex:3]] intValue] - 1;
            GLuint normalIndex2 = [[line substringWithRange: [result rangeAtIndex:6]] intValue] - 1;
            GLuint normalIndex3 = [[line substringWithRange: [result rangeAtIndex:9]] intValue] - 1;
            [self.normalIndexData appendBytes:(void *)(&normalIndex1) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex2) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex3) length:sizeof(GLuint)];
        }
    }
}


@end
