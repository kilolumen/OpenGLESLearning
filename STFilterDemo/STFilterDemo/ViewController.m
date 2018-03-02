//
//  ViewController.m
//  STFilterDemo
//
//  Created by Yangtsing.Zhang on 2018/1/30.
//  Copyright © 2018年 BeiTianSoftware. All rights reserved.
//

#import "ViewController.h"
#import "SRTBeautifyFilter.h"
#import "GPUImageVideoCamera.h"
#import "GPUImageView.h"
#import "GPUImageStillCamera.h"
#import "SRTSenseTimeSDKWrapper.h"
#import <AVFoundation/AVFoundation.h>

#define USING_BEAUTY_FILTER 1

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *displayView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) SRTBeautifyFilter *beautyF;
@property (nonatomic, strong) GPUImageCropFilter *cropF;
@property (nonatomic, strong) GPUImageSketchFilter *sketchF;
@property (nonatomic, strong) UIButton *shootPicBtn;
@property (nonatomic, strong) UIImageView *previewImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat w = CGRectGetWidth([UIScreen mainScreen].bounds) - 30;
    CGFloat h = CGRectGetHeight([UIScreen mainScreen].bounds) - 120;
    CGRect renderFrame = CGRectMake(15, 15, w, h);
    _displayView = [[GPUImageView alloc] initWithFrame: renderFrame];
    _displayView.backgroundColor = [UIColor yellowColor];
    [_displayView setInputRotation: kGPUImageFlipHorizonal atIndex: 0];
    [self.view addSubview: _displayView];
    
    _shootPicBtn = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_shootPicBtn setBackgroundColor: [UIColor orangeColor]];
    _shootPicBtn.frame = CGRectMake(0, 0, 80, 40);
    _shootPicBtn.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(_displayView.frame) + 25);
    [_shootPicBtn addTarget: self action:@selector(takePicture) forControlEvents: UIControlEventTouchUpInside];
    [_shootPicBtn setTitle:@"拍摄" forState: UIControlStateNormal];
    [self.view addSubview: _shootPicBtn];
    
    _previewImgView = [[UIImageView alloc] init];
    _previewImgView.frame = CGRectMake(CGRectGetMaxX(_shootPicBtn.frame) + 5, CGRectGetMinY(_shootPicBtn.frame), 50, 80);
    [self.view addSubview: _previewImgView];
    _previewImgView.backgroundColor = [UIColor yellowColor];
    
    [self initFilter];
    [self initCamera];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [_camera resumeCameraCapture];
    [_camera startCameraCapture];
}

- (void)initCamera{
    NSString *session = AVCaptureSessionPresetHigh;//AVCaptureSessionPresetHigh;
    _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:session cameraPosition: AVCaptureDevicePositionFront];
    //stillCamera.delegate = self;
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    CGRect cropr = CGRectMake(0, 0, 1.0, 0.6);
    int caseI = 3;
    if (caseI == 1)//CROPRECT4x3
    {
        cropr = CGRectMake(0, 0.2890625, 1.0, 0.421875);
    }
    else if (caseI == 2)//CROPRECT16x9
    {
        cropr = CGRectMake(0, 0.341796875, 1.0, 0.31640625);
    }else if (caseI == 3){
        cropr = CGRectMake(0.0, 0.0, 1.0, 0.99);
    }
    _cropF = [[GPUImageCropFilter alloc] initWithCropRegion:cropr];
    _sketchF = [[GPUImageSketchFilter alloc] init];
    
    //相机->裁剪->美颜  ， 预览效果正常，但点击拍摄，取出来的图是黑屏
#ifdef USING_BEAUTY_FILTER
    [_camera addTarget: _cropF];
    [_cropF addTarget: _beautyF];
    [_beautyF addTarget: _displayView];
#else
    //相机->裁剪->素描  ， 预览效果正常，点击拍摄，取出来的图也是正常的
    [_camera addTarget: _cropF];
    [_cropF addTarget: _sketchF];
    [_sketchF addTarget: _displayView];
#endif
}

- (void)initFilter{
    [SRTSenseTimeSDKWrapper_Instance createHandlesOfType: ST_INPUT_TYPE_VIDEO];
    _beautyF = [[SRTBeautifyFilter alloc] init];
}

#pragma mark - Action
- (void)takePicture{
#ifdef USING_BEAUTY_FILTER
    [_camera capturePhotoAsImageProcessedUpToFilter: _beautyF withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        UIImage *retImg = processedImage;//只要加了美颜滤镜，这个返回图像就是黑屏
        dispatch_async(dispatch_get_main_queue(), ^{
            _previewImgView.image = retImg;
        });
    }];
#else
    [_camera capturePhotoAsImageProcessedUpToFilter: _sketchF withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        UIImage *retImg = processedImage;//只要加了美颜滤镜，这个返回图像就是黑屏
        dispatch_async(dispatch_get_main_queue(), ^{
            _previewImgView.image = retImg;
        });
    }];
#endif
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
