//
//  CYPhotoPicker.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPicker.h"
#import "CYPhotoHeader.h"
#import "CYAlbum.h"
#import "CYPhotoNavigationViewController.h"
#import "CYPhotoCommon.h"
#import "CYPhotoAlbumListController.h"
#import "CYPhotoBrowserController.h"
#import "CYPhotoCenter.h"
#import "CYPhotoManager.h"
#import "CYAsset.h"

@interface CYPhotoPicker()

//显示选择器的控制器
@property (nonatomic, weak) UIViewController * sender;

@end

@implementation CYPhotoPicker {
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
}

- (void)clearInfo {
    [[CYPhotoCenter shareCenter] clearInfos];
}

- (void)showInSender:(UIViewController *)sender isSingleSel:(BOOL)isSingleSel isPushToCameraRoll:(BOOL)isPushToCameraRoll handle:(void(^)(NSArray<UIImage *> *photos, NSArray<CYAsset *> *assets))handle {

    [CYPhotoCenter shareCenter].maxSelectedCount = self.maxSelectedCount;
    [CYPhotoCenter shareCenter].minSelectedCount = self.minSelectedCount;
    
    self.sender = sender;
    
    [[CYPhotoCenter shareCenter] requestPhotoLibaryAuthorizationValidAuthorized:^{
        
        CYPhotoAlbumListController * albumsList = [[CYPhotoAlbumListController alloc] init];
        
        [[CYPhotoManager manager] fetchAllAlbumsAllowPickingVideo:NO allowPickingImage:YES needFetchAssets:YES completion:^(NSArray<CYAlbum *> *albumsArray) {
            
            albumsList.assetCollections = albumsArray;
        }];
        albumsList.isSingleSel = isSingleSel;
        
        CYPhotoNavigationViewController *nav = [[CYPhotoNavigationViewController alloc] initWithRootViewController:albumsList];
        nav.navigationBar.barTintColor = CYPHOTOLIB_NAV_BAR_COLOR;
        [nav.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blackColor]}];
        nav.navigationBar.tintColor = [UIColor blackColor];
        nav.navigationItem.backBarButtonItem.title = @"照片";
       
        if (isPushToCameraRoll) {
            [[CYPhotoManager manager] fetchCameraRollAlbumAllowPickingVideo:NO allowPickingImage:YES needFetchAssets:NO completion:^(CYAlbum *model) {
                
                CYAlbum *album;
                for (CYAlbum *mm in albumsList.assetCollections) {
                    if ([model.albumId isEqualToString:mm.albumId]) {
                        album = mm;
                    }
                }
                
                CYPhotoBrowserController * browser = [[CYPhotoBrowserController alloc] init];
                browser.isSingleSel = isSingleSel;
                browser.info = album;
                browser.assets = album.assets;
                browser.collectionTitle = album.name;
                [albumsList.navigationController pushViewController:browser animated:NO];
            }];
        }

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
        
        
        if (@available(iOS 10, *)) {
            // 跳转到 “设置\"-\"隐私\"-\"照片”
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CY_GotoPhotoLibrarySettingPath] options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
                NSLog(@"%@", success ? @"success" : @"failure");
            }];
        } else {
            // 跳转到 “设置\"-\"隐私\"-\"照片”
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CY_GotoPhotoLibrarySettingPath]];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self.sender presentViewController:alert animated:YES completion:nil];
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = @"正在处理";
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}


@end
