//
//  GLObject.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/6.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@implementation GLObject

- (instancetype)initWithGLContext:(GLContext *)context
{
    self = [super init];
    
    if (self) {
        
        self.context = context;
        
        return self;
    }
    
    return self;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glcontext
{
    
}
@end
