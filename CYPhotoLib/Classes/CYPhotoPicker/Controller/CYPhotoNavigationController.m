//
//  CYPhotoNavigationViewController.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/11/10.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoNavigationController.h"
#import "CYPhotoCenter.h"
#import "CYPhotoConfig.h"

@interface CYPhotoNavigationController ()

@end

@implementation CYPhotoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 横屏
- (BOOL)shouldAutorotate {
    return [CYPhotoCenter shareCenter].config.isShouldAutorotate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
