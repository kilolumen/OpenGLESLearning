//
//  GLObjectLoadFromOBJ.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/14.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface GLObjectLoadFromOBJ : GLObject
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
- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath;
- (void)loadDataFromObJFile:(NSString *)filePath;
- (void)decompressToVertexArray;
- (void)genBufferObjects;
- (void)genVAO;
@end
