//
//  CYPhotoBaseController.m
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoCenter.h"
#import "CYPhotoConfig.h"

@interface CYPhotoBaseController ()

@end

@implementation CYPhotoBaseController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
