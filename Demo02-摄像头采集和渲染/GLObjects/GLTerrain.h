//
//  GLTerrain.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/11.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface GLTerrain : GLObject
- (instancetype)initWithGLContext:(GLContext *)context heightMap:(UIImage *)image size:(CGSize)terrainSize height:(CGFloat)terrainHeight grass:(GLKTextureInfo *)grassTexture dirt:(GLKTextureInfo *)dirtTexture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
