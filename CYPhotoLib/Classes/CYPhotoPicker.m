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
#import "CYPhotoAsset.h"

#import "CYPhotoCenter.h"
#import "CYPhotoConfig.h"
#import "NSBundle+CYPhotoLib.h"

@interface CYPhotoPicker()

// 配置
@property (nonatomic, strong) CYPhotoConfig *config;

@end

@implementation CYPhotoPicker 

#pragma mark - public
- (void)showInSender:(__kindof UIViewController *)sender handler:(void(^)(NSArray<PHAsset *> *assets))handler {
    [self showInSender:sender config:self.config handler:handler];
}

- (void)showInSender:(__kindof UIViewController *)sender config:(CYPhotoConfig *)config handler:(void(^)(NSArray<PHAsset *> *assets))handler {
    
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
        
        [sender presentViewController:navigationController animated:YES completion:nil];
        
    } denied:^{
        [self deined:sender];
    } restricted:^{
        [self restricted:sender];
    } elseBlock:^{
        
    }];
    
    [[CYPhotoCenter shareCenter] setHandler:^(NSArray<CYPhotoAsset *> *photos) {
        
        // FIX： 如果是单张 清除信息，下次进来就没有了
        if (CYPhotoCenter.config.isSinglePick) {
            [self clearInfo];
        }
        
        NSMutableArray *assetArray = [NSMutableArray array];
        
        [[CYPhotoCenter shareCenter].selectedPhotos enumerateObjectsUsingBlock:^(CYPhotoAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [assetArray addObject:obj.asset];
        }];
        handler(assetArray);
    }];
}

- (void)clearInfo {
    [[CYPhotoCenter shareCenter] clearInfos];
}

#pragma mark - private
- (void)deined:(UIViewController *)sender {
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
    [self setAlertControllerWithTitle:[NSBundle cy_localizedStringForKey:@"The application cannot access your photo album"] message:[NSString stringWithFormat:[NSBundle cy_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> %@ -> Photos\""],appName, appName] sender:sender];
    return;
}

- (void)restricted:(UIViewController *)sender {
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
    [self setAlertControllerWithTitle:[NSBundle cy_localizedStringForKey:@"The application was unable to access the photo because parental control was enabled"] message:[NSString stringWithFormat:[NSBundle cy_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> %@ -> Photos\""], appName, appName] sender:sender];
    return;
}

- (void)setAlertControllerWithTitle:(NSString *)title message:(NSString *)message sender:(UIViewController *)sender {
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
    
    [sender presentViewController:alert animated:YES completion:nil];
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
//- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
//    self.config.allowPickingVideo = allowPickingVideo;
//}

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

// disabled data length
- (void)setMinDisabledDataLength:(CGFloat)minDisabledDataLength {
    self.config.minDisabledDataLength = minDisabledDataLength;
}
- (void)setMaxDisabledDataLength:(CGFloat)maxDisabledDataLength {
    self.config.maxDisabledDataLength = maxDisabledDataLength;
}


// warning data length
- (void)setMinWarningDataLength:(CGFloat)minWarningDataLength {
    self.config.minWarningDataLength = minWarningDataLength;
}

//- (void)setMaxWarningDataLength:(CGFloat)maxWarningDataLength {
//    self.config.maxWarningDataLength = maxWarningDataLength;
//}


//// disabled size
//- (void)setMinDisabledSize:(CGSize)minDisabledSize {
//    self.config.minDisabledSize = minDisabledSize;
//}
//
//- (void)setMaxDisabledSize:(CGSize)maxDisabledSize {
//    self.config.maxDisabledSize = maxDisabledSize;
//}
//
//// warning size
//- (void)setMinWarningSize:(CGSize)minWarningSize {
//    self.config.minWarningSize = minWarningSize;
//}
//- (void)setMaxWarningSize:(CGSize)maxWarningSize {
//    self.config.maxWarningSize = maxWarningSize;
//}

// disabled aspect ratio
- (void)setDisabledAspectRatio:(CGFloat)disabledAspectRatio {
    self.config.disabledAspectRatio = disabledAspectRatio;
}
// waring aspect ratio
- (void)setWarningAspectRatio:(CGFloat)warningAspectRatio {
    self.config.warningAspectRatio = warningAspectRatio;
}

- (void)setShowCountFooter:(BOOL)showCountFooter {
    self.config.showCountFooter = showCountFooter;
}

@end
