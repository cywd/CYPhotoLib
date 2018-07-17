//
//  CYPhotoPicker.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPicker.h"

#import "CYPhotoHeader.h"
#import "CYPhotoCommon.h"

#import "CYPhotoNavigationController.h"
#import "CYPhotoAlbumsController.h"
#import "CYPhotoAssetsController.h"

#import "CYPhotoCenter.h"
#import "CYPhotoConfig.h"
#import "NSBundle+CYPhotoLib.h"

@interface CYPhotoPicker()

// 配置
@property (nonatomic, strong) CYPhotoConfig *config;
// 显示选择器的控制器
@property (nonatomic, weak) UIViewController * sender;

@end

@implementation CYPhotoPicker 

#pragma mark - public
- (void)showInSender:(__kindof UIViewController *)sender handle:(void(^)(NSArray<UIImage *> *photos, NSArray<CYAsset *> *assets))handle {
    [self showInSender:sender config:self.config handle:handle];
}

- (void)showInSender:(__kindof UIViewController *)sender config:(CYPhotoConfig *)config handle:(void(^)(NSArray<UIImage *> *photos, NSArray<CYAsset *> *assets))handle {

    self.sender = sender;
    
    [CYPhotoCenter shareCenter].config = config;
    
    [[CYPhotoCenter shareCenter] requestPhotoLibaryAuthorizationValidAuthorized:^{
        
        // 相册列表
        CYPhotoAlbumsController * albumsViewController = [[CYPhotoAlbumsController alloc] init];
        
        CYPhotoNavigationController *navigationController = [[CYPhotoNavigationController alloc] initWithRootViewController:albumsViewController];
        
        if (CYPhotoCenter.config.isPushToCameraRoll) {
            // 所有照片
            CYPhotoAssetsController *assetsViewController = [[CYPhotoAssetsController alloc] init];
            [albumsViewController.navigationController pushViewController:assetsViewController animated:NO];
        }
        
        [self.sender presentViewController:navigationController animated:YES completion:nil];
        
    } denied:^{
        [self deined];
    } restricted:^{
        [self restricted];
    } elseBlock:^{
        
    }];
    
    [[CYPhotoCenter shareCenter] setHandle:^(NSArray<UIImage *> * photos) {
        
        // FIX： 如果是单张 清除信息，下次进来就没有了
        if (CYPhotoCenter.config.isSinglePick) {
            [self clearInfo];
        }
        
        NSMutableArray *assetArray = [CYPhotoCenter shareCenter].selectedPhotos;
        
        handle(photos, assetArray);
    }];
}

- (void)clearInfo {
    [[CYPhotoCenter shareCenter] clearInfos];
}

#pragma mark - private
- (void)deined {
    // 无权限
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
    [self setAlertControllerWithTitle:[NSBundle cy_localizedStringForKey:@"The application cannot access your photo album"] message:[NSString stringWithFormat:[NSBundle cy_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> %@ -> Photos\""],appName, appName]];
    return;
}

- (void)restricted {
    // 家长模式
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
    [self setAlertControllerWithTitle:[NSBundle cy_localizedStringForKey:@"The application was unable to access the photo because parental control was enabled"] message:[NSString stringWithFormat:[NSBundle cy_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> %@ -> Photos\""], appName, appName]];
    return;
}

- (void)setAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle cy_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle cy_localizedStringForKey:@"Setting"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (@available(iOS 10, *)) {
            // 跳转到 “设置\"-\"隐私\"-\"照片”
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
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

#pragma mark - getter
- (CYPhotoConfig *)config
{
    if (!_config) {
        _config = [[CYPhotoConfig alloc] init];
    }
    return _config;
}

#pragma mark - setter
- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    self.config.allowPickingVideo = allowPickingVideo;
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    self.config.allowPickingImage = allowPickingImage;
}

- (void)setPushToCameraRoll:(BOOL)pushToCameraRoll {
    self.config.pushToCameraRoll = pushToCameraRoll;
}

- (void)setSinglePick:(BOOL)singlePick {
    self.config.singlePick = singlePick;
}

- (void)setSortByModificationDate:(BOOL)sortByModificationDate {
    self.config.sortByModificationDate = sortByModificationDate;
}

- (void)setAscending:(BOOL)ascending {
    self.config.ascending = ascending;
}

- (void)setDefaultImageWidth:(CGFloat)defaultImageWidth {
    self.config.defaultImageWidth = defaultImageWidth;
}

- (void)setMaxSelectedCount:(NSInteger)maxSelectedCount {
    self.config.maxSelectedCount = maxSelectedCount;
}

- (void)setMinSelectedCount:(NSInteger)minSelectedCount {
    self.config.minSelectedCount = minSelectedCount;
}

- (void)setEdgeInset:(UIEdgeInsets)edgeInset {
    self.config.edgeInset = edgeInset;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    self.config.columnNumber = columnNumber;
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    self.config.minimumLineSpacing = minimumLineSpacing;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    self.config.minimumInteritemSpacing = minimumInteritemSpacing;
}

- (void)setShowCountFooter:(BOOL)showCountFooter {
    self.config.showCountFooter = showCountFooter;
}

@end
