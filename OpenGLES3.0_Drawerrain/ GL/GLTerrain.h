//
//  GLTerrain.h
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/12.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@interface GLTerrain : GLObject
- (id)initWithGLContext:(GLContext *)context
              heightMap:(UIImage *)image
                   size:(CGSize)terrainSize
                 height:(GLfloat)terrainHeight
                  grass:(GLKTextureInfo *)gressTexture
                   dirt:(GLKTextureInfo *)dirtTexture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
