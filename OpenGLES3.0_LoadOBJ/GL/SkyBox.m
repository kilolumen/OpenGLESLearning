//
//  SkyBox.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/8.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "SkyBox.h"

@implementation SkyBox
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
