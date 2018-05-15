//
//  FeaturePointCloud.h
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/5/12.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "GLObject.h"
#import <ARKit/ARKit.h>

@interface FeaturePointCloud : GLObject
- (id)initWithGLContext:(GLContext *)context;
- (void)setCloudData:(ARPointCloud *)pointCloud;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glcontext;
@end
