//
//  ViewController.m
//  WI3DStickerDemo
//
//  Created by ycpeng on 2017/9/4.
//  Copyright © 2017年 ycpeng. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "WISenseTime3DRender.h"
#import "WISenseTimeFaceDetectionAdaptor.h"

@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *preview;
@property (nonatomic, strong) WISenseTimeFaceDetectionAdaptor *adaptor;

@property (nonatomic, strong) WISenseTime3DRender *filter;

@end

@implementation ViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_preview];
    
    self.filter = [WISenseTime3DRender new];
    
    //配置人脸检测
    self.adaptor = [[WISenseTimeFaceDetectionAdaptor alloc] initWithType:WISenseTimeFaceDetectionAdaptorTypeVideo];
    [_adaptor setupHandleWithOptions:WIActionDetectOptionFaceAll] ;
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _videoCamera.delegate = self;
    [_videoCamera rotateCamera];
    
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"3d_sticker" ofType:@"bundle"] stringByAppendingPathComponent:@"glassFour.zip"];
    __weak typeof(self) wkSelf = self;
    [self.filter setStickerWithFilePath:path result:^(BOOL success, WIActionDetectOption actionOptions) {
        [wkSelf.videoCamera addTarget:wkSelf.filter];
    }];
    
    [_filter addTarget:_preview];
    
    [_videoCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    WISenseTimeFaceGroup *faceGroup = [_adaptor faceFromCameraSampleBuffer:sampleBuffer isMirror:YES];
    [_filter setFaceGroup:faceGroup];
}

@end
