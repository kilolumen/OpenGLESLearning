//
//  GLObject.m
//  OpenGLES3.0_Drawerrain
//
//  Created by sensetimesunjian on 2018/1/11.
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
    
    return self;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate
{
    
}

- (void)draw:(GLContext *)glContext
{
    
}
@end
