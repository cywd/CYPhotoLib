//
//  CYPhotoCenter.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2016/9/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoCenter.h"
#import "CYPhotoHeader.h"

@interface CYPhotoCenter () <PHPhotoLibraryChangeObserver, UIAlertViewDelegate>

@end

@implementation CYPhotoCenter

+ (instancetype)shareCenter
{
    static CYPhotoCenter * center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[CYPhotoCenter alloc] init];
        center.selectedPhotos = [NSMutableArray array];
    });
    return center;
}

#pragma mark - 获取所有图片
- (void)fetchAllAsset {
    [self clearInfos];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self photoLibaryAuthorizationValid];
}

- (void)reloadPhotos {
    self.allPhotos = [[CYPhotoManager manager] fetchAllAssets];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoLibraryChangeNotification object:nil];
}

#pragma mark - 完成图片选择
- (void)endPickWithImage:(UIImage *)cameraPhoto {
    if (self.handle) self.handle(@[cameraPhoto]);
}

- (void)endPick {
    if (self.handle) {
        [[CYPhotoManager manager] fetchImagesWithAssetsArray:self.selectedPhotos isOriginal:self.isOriginal completeBlock:^(NSArray *images) {
            self.handle(images);
        }];
    }
}

- (BOOL)isReachMaxSelectedCount {
    if (self.selectedPhotos.count >= self.maxSelectedCount) {
//        NSString *msg = [NSString stringWithFormat:@"最多只能选择%ld张", self.maxSelectedCount];
//        ShowMsg(msg);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isReachMinSelectedCount {
    
    if (self.selectedPhotos.count < self.minSelectedCount) {
//        NSString *msg = [NSString stringWithFormat:@"至少要选择%ld张", self.minSelectedCount];
//        ShowMsg(msg);
        return YES;
    }
    return NO;
}

#pragma mark - 清除信息
- (void)clearInfos {
    self.selectedCount = 20;
    self.maxSelectedCount = 20;
    self.minSelectedCount = 1;
    self.isOriginal = NO;
    self.handle = nil;
    self.allPhotos = nil;
    [self.selectedPhotos removeAllObjects];
//    self.selectedPhotos = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - 监听图片变化代理
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    //此代理方法里的线程非主线程
    [self reloadPhotos];
}

#pragma mark - 权限验证
- (void)photoLibaryAuthorizationValid {
    PHAuthorizationStatus authoriation = [PHPhotoLibrary authorizationStatus];
    if (authoriation == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //这里非主线程，选择完成后会出发相册变化代理方法
        }];
    }else if (authoriation == PHAuthorizationStatusAuthorized) {
        [self reloadPhotos];
    }else {
//        UIAlertView * photoLibaryNotice = [[UIAlertView alloc]initWithTitle:@"不能预览图片" message:@"应用程序无访问照片权限, 请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil];
//        [photoLibaryNotice show];
    }
}

- (void)cameraAuthoriationValidWithHandle:(void(^)())handle {
    AVAuthorizationStatus authoriation = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authoriation == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handle) handle();
                });
            }
        }];
    } else if (authoriation == AVAuthorizationStatusAuthorized) {
        if (handle) handle();
    } else {
//        UIAlertView * cameraNotice = [[UIAlertView alloc]initWithTitle:@"应用程序无访问相机权限" message:@"请在“设置\"-\"隐私\"-\"相机”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil];
//        [cameraNotice show];
    }
}

#pragma mark - AlertView代理
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex) {
//        NSURL * setting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        if ([[UIApplication sharedApplication]canOpenURL:setting]) {
//            [[UIApplication sharedApplication]openURL:setting];
//        }
//    }
//}

@end
