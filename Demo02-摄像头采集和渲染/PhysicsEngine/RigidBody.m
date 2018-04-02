//
//  RigidBody.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/29.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "RigidBody.h"

@implementation RigidBody
- (void)commonInit{
    self.mass = 1.0;
    self.velocity = GLKVector3Make(0, 0, 0);
    self.restitution = 0.2;
    self.friction = 0.3;
}

- (instancetype)initAsBox:(GLKVector3)size
{
    self = [super init];
    if (self) {
        RigidBodyShape rigidBodyShape;
        rigidBodyShape.type = RigidBodyShapeTypeBox;
        rigidBodyShape.shapes.box.size = size;
        self.rigidBodyShape = rigidBodyShape;
        
        [self commonInit];
    }
    return self;
}
@end
