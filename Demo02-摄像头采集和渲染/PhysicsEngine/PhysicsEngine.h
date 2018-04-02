//
//  PhysicsEngine.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/29.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RigidBody.h"

@interface PhysicsEngine : NSObject
- (void)update:(NSTimeInterval)deltaTime;
- (void)addRigidBody:(RigidBody *)rigidBody;
@end
