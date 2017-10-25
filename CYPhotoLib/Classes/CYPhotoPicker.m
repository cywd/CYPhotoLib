//
//  CYPhotoPicker.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPicker.h"
#import "CYPhotoHeader.h"
#import "CYAblumModel.h"
#import "CYPhotoNavigationViewController.h"
#import "CYPhotoCommon.h"
#import "NSString+CYPHChineseName.h"
#import "CYPhotoAblumListController.h"
#import "CYPhotoBrowserController.h"
#import "CYPhotoCenter.h"
#import "CYPhotoManager.h"

@interface CYPhotoPicker()

//显示选择器的控制器
@property (nonatomic, weak) UIViewController * sender;

@end

@implementation CYPhotoPicker

- (void)clearInfo {
    [[CYPhotoCenter shareCenter] clearInfos];
}

- (void)showInSender:(UIViewController *)sender isSingleSel:(BOOL)isSingleSel handle:(void(^)(NSArray<UIImage *> *photos, NSArray<PHAsset *> *assets))handle {

    [CYPhotoCenter shareCenter].maxSelectedCount = self.maxSelectedCount;
    [CYPhotoCenter shareCenter].minSelectedCount = self.minSelectedCount;
    
    self.sender = sender;
    
    [[CYPhotoCenter shareCenter] requestPhotoLibaryAuthorizationValidAuthorized:^{
        CYPhotoAblumListController * ablumsList = [[CYPhotoAblumListController alloc]init];
        ablumsList.assetCollections = [[CYPhotoManager manager] getAllAblums];
        ablumsList.isSingleSel = isSingleSel;
        
        CYPhotoNavigationViewController *nav = [[CYPhotoNavigationViewController alloc] initWithRootViewController:ablumsList];
        nav.navigationBar.barTintColor = CYPHOTOLIB_NAV_BAR_COLOR;
        [nav.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blackColor]}];
        nav.navigationBar.tintColor = [UIColor blackColor];
        nav.navigationItem.backBarButtonItem.title = @"照片";
        //默认跳转到照片图册
        CYPhotoBrowserController * browser = [[CYPhotoBrowserController alloc] init];
        browser.isSingleSel = isSingleSel;
        if (ablumsList.assetCollections) {
            CYAblumModel *info = [ablumsList.assetCollections firstObject];
            
            browser.info = info;
            browser.assetCollection = info.assetCollection;
            browser.collectionTitle = [info.ablumName chineseName];
//            browser.collectionTitle = NSLocalizedString(info.ablumName, @"");
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
        
        // FIX： 如果是单张 清除信息，下次进来就没有了
        if (isSingleSel) {
            [self clearInfo];
        }
        
        NSMutableArray *assetArray = [CYPhotoCenter shareCenter].selectedPhotos;
        
        handle(photos, assetArray);
        
    }];
}

- (void)deined {
    // 无权限
    [self setAlertControllerWithTitle:CY_DeinedPhotoLibirayText message:CY_GotoPhotoLibararySettingText];
    
    return;
}

- (void)restricted {
    // 家长模式
    [self setAlertControllerWithTitle:CY_RestrictedPhotoLibirayText message:CY_GotoPhotoLibararySettingText];
    
    return;
}

- (void)setAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到 “设置\"-\"隐私\"-\"照片”
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CY_GotoPhotoLibrarySettingPath]];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self.sender presentViewController:alert animated:YES completion:nil];
}

@end
