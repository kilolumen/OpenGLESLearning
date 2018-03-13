//
//  STFlashFilter.m
//  STFilterDemo
//
//  Created by sensetimesunjian on 2018/3/13.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "STFlashFilter.h"


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageFlashFragmentShaderString = SHADER_STRING
(
 
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((1.0 - textureColor.rgb), textureColor.w);
 }
 );
#else
#endif


@implementation STFlashFilter
- (id)init
{
    self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImageFlashFragmentShaderString];
    
    if (!self) {
        
        return nil;
    }
    
    return self;
}

@end
