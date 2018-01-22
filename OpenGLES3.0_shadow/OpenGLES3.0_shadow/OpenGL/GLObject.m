//
//  GLObject.m
//  OpenGLES3.0_shadow
//
//  Created by sensetimesunjian on 2018/1/22.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "GLObject.h"

@implementation GLObject

- (id)initWithGLContext:(GLContext *)context
{
    self = [super init];
    
    if (self) {
        
        self.context = context;
        
        return self;
    }
    
    return nil;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glContext
{
    
}
@end
