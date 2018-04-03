//
//  Billboard.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/4/2.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"

@interface Billboard : GLObject
@property (nonatomic, assign) GLKVector2 billboardSize;
@property (nonatomic, assign) GLKVector3 billboardCenterPosition;
@property (nonatomic, assign) BOOL lockToYAxis;

- (instancetype)initWithGLContext:(GLContext *)context texture:(GLKTextureInfo *)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
