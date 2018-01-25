//
//  TableViewController.m
//  OpenGLES3.0_LoadOBJ
//
//  Created by sensetimesunjian on 2018/1/16.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "TableViewController.h"
#import "LoadOBJViewController.h"
#import "HightLevelLuminationVC.h"
#import "normalMapViewController.h"
#import "textureShadowViewController.h"

@interface TableViewController ()
@property (nonatomic, strong) NSArray *arrItems;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrItems = @[@"loadOBJ",
                  @"hightLevellumin",
                  @"normalMap",
                  @"textureShadow"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _arrItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"identify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    cell.textLabel.text = _arrItems[indexPath.item];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *vc;
    
    switch (indexPath.item) {
        case 0:
            vc = [[LoadOBJViewController alloc] init];
            break;
        case 1:
            vc = [[HightLevelLuminationVC alloc] init];
            break;
        case 2:
            vc = [[normalMapViewController alloc] init];
            break;
        case 3:
            vc = [[textureShadowViewController alloc] init];
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
