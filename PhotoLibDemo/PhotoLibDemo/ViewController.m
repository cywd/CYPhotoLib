//
//  ViewController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/6/20.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "ViewController.h"
#import "CYPhotoAblumListController.h"
#import "CYPhotoManager.h"
#import "CYPhotoBrowserController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(UIButton *)sender {
    
}

- (IBAction)btnClick:(UIButton *)sender {
    
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        UIAlertView * photoLibaryNotice = [[UIAlertView alloc]initWithTitle:@"应用程序无访问照片权限" message:@"请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil];
        [photoLibaryNotice show];
        return;
    }
    CYPhotoAblumListController * ablumsList = [[CYPhotoAblumListController alloc]init];
    ablumsList.assetCollections = [[CYPhotoManager manager]getAllAblums];
    UINavigationController * NVC = [[UINavigationController alloc]initWithRootViewController:ablumsList];
    //默认跳转到照片图册
    CYPhotoBrowserController * browser = [[CYPhotoBrowserController alloc] init];
    [ablumsList.navigationController pushViewController:browser animated:NO];
    [self presentViewController:NVC animated:YES completion:nil];
    
    
}

@end
