//
//  STLaunchAdController.m
//  STLaunchAdDemo
//
//  Created by sensetimesunjian on 2018/2/24.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "STLaunchAdController.h"
#import "STLaunchAdConst.h"

@interface STLaunchAdController ()

@end

@implementation STLaunchAdController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden{
    return STLaunchAdPrefersHomeIndicatorAutoHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
