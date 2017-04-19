//
//  CYPhotoPicker.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPicker.h"
#import "CYPhotoHeader.h"
#import "CYAblumInfo.h"
#import "CYPhotoNavigationViewController.h"

@interface CYPhotoPicker()

//显示选择器的控制器
@property (nonatomic, weak) UIViewController * sender;

@end

@implementation CYPhotoPicker

- (void)clearInfo {
    [[CYPhotoCenter shareCenter] clearInfos];
}

- (void)showInSender:(UIViewController *)sender isSingleSel:(BOOL)isSingleSel handle:(void(^)(NSArray *photos))handle {
    
    [CYPhotoCenter shareCenter].maxSelectedCount = self.maxSelectedCount;
    [CYPhotoCenter shareCenter].minSelectedCount = self.minSelectedCount;
    
    self.sender = sender;
    
    
    [[CYPhotoCenter shareCenter] requestPhotoLibaryAuthorizationValidAuthorized:^{
        
        CYPhotoAblumListController * ablumsList = [[CYPhotoAblumListController alloc]init];
        ablumsList.assetCollections = [[CYPhotoManager manager] getAllAblums];
        ablumsList.isSingleSel = isSingleSel;
        
        CYPhotoNavigationViewController *nav = [[CYPhotoNavigationViewController alloc] initWithRootViewController:ablumsList];
        nav.navigationBar.barTintColor = [UIColor purpleColor];
        [nav.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blackColor]}];
        nav.navigationBar.tintColor = [UIColor blackColor];
        nav.navigationItem.backBarButtonItem.title = @"照片";
        //默认跳转到照片图册
        CYPhotoBrowserController * browser = [[CYPhotoBrowserController alloc] init];
        browser.isSingleSel = isSingleSel;
        if (ablumsList.assetCollections) {
            CYAblumInfo *info = [ablumsList.assetCollections firstObject];
            
            browser.info = info;
            browser.assetCollection = info.assetCollection;
            browser.collectionTitle = [info.ablumName chineseName];
        }
        
        [ablumsList.navigationController pushViewController:browser animated:NO];
        
        [self.sender presentViewController:nav animated:YES completion:nil];
        
    } denied:^{
        [self deined];
    } restricted:^{
        [self restricted];
    } elseBlock:^{
        
    }];
    
    [[CYPhotoCenter shareCenter] setHandle:^(NSArray<UIImage *> * photos) {
        
        //                NSMutableArray *assetArray = [CYPhotoCenter shareCenter].selectedPhotos;
        
        handle(photos);
    }];
    
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
    
    [self.sender presentViewController:alert animated:YES completion:nil];
    
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
    
    [self.sender presentViewController:alert animated:YES completion:nil];
    
    return;
}

@end
