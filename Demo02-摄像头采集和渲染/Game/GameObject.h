//
//  GameObject.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/29.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import "RigidBody.h"

@interface GameObject : NSObject
@property (strong, nonatomic) GLObject * geometry;
@property (strong, nonatomic) RigidBody * rigidBody;

- (instancetype)initWithGeometry:(GLObject *)geometry rigidBody:(RigidBody *)rigidBody;
- (void)update:(NSTimeInterval)deltaTime;
@end
