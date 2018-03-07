//
//  ViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by loyinglin on 16/5/10.
//  Copyright © 2016年 loyinglin. All rights reserved.
//

#import "ViewController.h"
#import "LYOpenGLView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
//#import "STAVPlayer.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //
@property (nonatomic , strong) AVCaptureConnection *videoConnection;
// OpenGL ES
@property (nonatomic , strong)  LYOpenGLView *mGLView;
//@property (nonatomic , strong)  STAVPlayer *stPlayer;
@property (nonatomic) CVPixelBufferRef rgbaPixelBuffer;
@property (nonatomic , strong) NSMutableArray *points;
@end


@implementation ViewController
{
    dispatch_queue_t mProcessQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mGLView = (LYOpenGLView *)self.view;
    [self.mGLView setupGL];
    
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    self.mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    mProcessQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            inputCamera = device;
        }
    }
    
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }

    
    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    self.mGLView.isFullYUVRange = YES;
    [self.mCaptureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:mProcessQueue];
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }
    
    _videoConnection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    
    
    [self.mCaptureSession startRunning];
    

    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
//
//    self.stPlayer = [[STAVPlayer alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"1" withExtension:@"MOV"]];
//
//    __weak typeof(self) weakSelf = self;
//
//    self.stPlayer.callBack = ^(CVPixelBufferRef pixelBuffer) {
//
//        weakSelf.rgbaPixelBuffer = pixelBuffer;
//    };
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [self.view addSubview:button];
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    //添加拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    
    _points = [NSMutableArray array];
    
    CGPoint leftBottom = CGPointMake(WIDTH - 60, 0);
    CGPoint leftTop    = CGPointMake(WIDTH - 60, 80);
    CGPoint rightBottom = CGPointMake(WIDTH, 0);
    CGPoint rightTop   = CGPointMake(WIDTH, 80);
    
    NSNumber *leftBottomX = [NSNumber numberWithFloat:leftBottom.x/WIDTH*2-1];
    NSNumber *leftBottomY = [NSNumber numberWithFloat:leftBottom.y/HEIGHT*2-1];
    NSNumber *leftTopX = [NSNumber numberWithFloat:leftTop.x/WIDTH*2-1];
    NSNumber *leftTopY = [NSNumber numberWithFloat:leftTop.y/HEIGHT*2-1];
    NSNumber *rightBottomX = [NSNumber numberWithFloat:rightBottom.x/WIDTH*2-1];
    NSNumber *rightBottomY = [NSNumber numberWithFloat:rightBottom.y/HEIGHT*2-1];
    NSNumber *rightTopX = [NSNumber numberWithFloat:rightTop.x/WIDTH*2-1];
    NSNumber *rightTopY = [NSNumber numberWithFloat:rightTop.y/HEIGHT*2-1];
    
    [_points addObject:leftBottomX];
    [_points addObject:leftBottomY];
    [_points addObject:leftTopX];
    [_points addObject:leftTopY];
    [_points addObject:rightBottomX];
    [_points addObject:rightBottomY];
    [_points addObject:rightTopX];
    [_points addObject:rightTopY];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    
}

- (void)play
{
//    [self.stPlayer play];
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == _videoConnection) {
        static long frameID = 0;
        ++frameID;
        CFRetain(sampleBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [self.mGLView displayPixelBuffer:pixelBuffer
                             rbgaPixelBuffer:_rgbaPixelBuffer
                                       array:_points];
            self.mLabel.text = [NSString stringWithFormat:@"%ld", frameID];
            CFRelease(sampleBuffer);
        });
    }
}

- (void)dealloc
{
    if (_rgbaPixelBuffer) {
        CFRelease(_rgbaPixelBuffer);
    }
}

#pragma mark - Simple Editor

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
