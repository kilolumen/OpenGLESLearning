//
//  SKYBox.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/4/1.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "SKYBox.h"

@implementation SKYBox
- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    [super update:timeSinceLastUpdate];
}

- (void)draw:(GLContext *)glcontext
{
    glCullFace(GL_FRONT);
    glDepthMask(GL_FALSE);
    [super draw:glcontext];
    glDepthMask(GL_TRUE);
    glCullFace(GL_BACK);
}
@end
