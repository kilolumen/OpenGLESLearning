//
//  Camera.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/2/4.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "Camera.h"

@implementation Camera
- (void)setupCameraWithEye:(GLKVector3)eye lookAt:(GLKVector3)lookAt up:(GLKVector3)up
{
    self.forward = GLKVector3Normalize(GLKVector3Subtract(lookAt, eye));
    self.up = GLKVector3Normalize(up);
    self.position = eye;
}

- (GLKVector3)reflect:(GLKVector3)sourceVector normalVector:(GLKVector3)normalVector
{
    CGFloat normalScalar = 2 * GLKVector3DotProduct(sourceVector, normalVector);//标量
    GLKVector3 scaledNormalVector = GLKVector3MultiplyScalar(normalVector, normalScalar);
    GLKVector3 reflectVector = GLKVector3Subtract(sourceVector, scaledNormalVector);
    return reflectVector;
}

- (void)mirrorTo:(Camera *)targetCamera plane:(GLKVector4)plane
{
    GLKVector3 planeNormal = GLKVector3Normalize(GLKVector3Make(plane.x, plane.y, plane.z));
}
@end
