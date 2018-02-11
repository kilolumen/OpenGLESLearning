//
//  Terrain.h
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/8.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@interface Terrain : GLObject
- (id)initWithGLContext:(GLContext *)context heightMap:(UIImage *)image
                   size:(CGSize)terrainSize
                 height:(CGFloat)terrainHeight
                  gress:(GLKTextureInfo *)gressTexture
                   dirt:(GLKTextureInfo *)dirtTexture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
