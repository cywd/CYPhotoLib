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

//#import <Photos/Photos.h>

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

/**
 *  [PHPhotoLibrary authorizationStatus]
 PHAuthorizationStatusDenied
 用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关
 PHAuthorizationStatusRestricted
 家长控制,不允许访问
 PHAuthorizationStatusNotDetermined
 用户还没有做出选择
 PHAuthorizationStatusAuthorized
 用户允许当前应用访问相册
 *
 */
- (IBAction)btnClick:(UIButton *)sender {
    
    [self gotoPhotos];
}

- (void)gotoPhotos
{
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusDenied:
            printf("PHAuthorizationStatusDenied - 用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
            [self deined];
            break;
        case PHAuthorizationStatusRestricted:
            printf("PHAuthorizationStatusRestricted - 家长控制,不允许访问");
            [self restricted];
            break;
        case PHAuthorizationStatusNotDetermined:
            printf("PHAuthorizationStatusNotDetermined - 还没有选择");
            break;
        case PHAuthorizationStatusAuthorized:
            printf("PHAuthorizationStatusAuthorized - 用户允许当前应用访问相册");
            break;
        default:
            break;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        if (status == PHAuthorizationStatusAuthorized) {
            [self jump];
        } else if (status == PHAuthorizationStatusDenied) {
            [self deined];
        } else if (status == PHAuthorizationStatusRestricted) {
            [self restricted];
        }
    }];
}

- (void)jump {
    
    CYPhotoAblumListController * ablumsList = [[CYPhotoAblumListController alloc]init];
    ablumsList.assetCollections = [[CYPhotoManager manager] getAllAblums];
    UINavigationController * NVC = [[UINavigationController alloc] initWithRootViewController:ablumsList];
    
    //默认跳转到照片图册
    CYPhotoBrowserController * browser = [[CYPhotoBrowserController alloc] init];
    [ablumsList.navigationController pushViewController:browser animated:NO];
    [self presentViewController:NVC animated:YES completion:nil];
}

- (void)deined {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"应用程序无访问照片权限" message:@"请在“设置\"-\"隐私\"-\"照片”中设置允许访问" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到 “设置\"-\"隐私\"-\"照片”
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    return;
}

- (void)restricted {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"由于开启了家长控制，应用程序无访问照片权限" message:@"请在“设置\"-\"隐私\"-\"照片”中设置允许访问" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到 “设置\"-\"隐私\"-\"照片”
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    return;
}

@end
