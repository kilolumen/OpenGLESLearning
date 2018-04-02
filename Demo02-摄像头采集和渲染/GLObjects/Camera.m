//
//  Camera.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/22.
//  Copyright © 2018年 林伟池. All rights reserved.
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
    CGFloat normalScale = 2 * GLKVector3DotProduct(sourceVector, normalVector);
    GLKVector3 scaledNormalVector = GLKVector3MultiplyScalar(normalVector, normalScale);
    GLKVector3 reflectVector = GLKVector3Subtract(sourceVector, scaledNormalVector);
    return reflectVector;
}

- (void)mirrorTo:(Camera *)targetCamera plane:(GLKVector4)plane
{
    GLKVector3 planeNormal = GLKVector3Normalize(GLKVector3Make(plane.x, plane.y, plane.z));
    GLKVector3 mirrorForward = GLKVector3Normalize([self reflect:self.forward normalVector:planeNormal]);
    GLKVector3 mirrorUp = GLKVector3Normalize([self reflect:self.up normalVector:planeNormal]);
    GLKVector3 planeCenter = GLKVector3MultiplyScalar(planeNormal, plane.w);
    GLKVector3 eyeVector = GLKVector3Subtract(planeCenter, self.position);
    GLfloat eyeVectorLength = GLKVector3Length(eyeVector);
    eyeVector = GLKVector3Normalize(eyeVector);
    GLKVector3 mirrorEyeVector = GLKVector3Normalize([self reflect:eyeVector normalVector:planeNormal]);
    mirrorEyeVector = GLKVector3MultiplyScalar(mirrorEyeVector, eyeVectorLength);
    GLKVector3 mirrorPosition = GLKVector3Subtract(planeCenter, mirrorEyeVector);
    
    targetCamera.position = mirrorPosition;
    targetCamera.up = mirrorUp;
    targetCamera.forward = mirrorForward;
}

- (GLKMatrix4)cameraMatrix
{
    GLKVector3 eye = self.position;
    GLKVector3 lookAt = GLKVector3Add(eye, self.forward);
    return GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z, lookAt.x, lookAt.y, lookAt.z, self.up.x, self.up.y, self.up.z);
}
@end
