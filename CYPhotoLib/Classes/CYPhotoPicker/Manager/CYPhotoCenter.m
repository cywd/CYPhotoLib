//
//  CYPhotoCenter.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2016/9/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoCenter.h"
#import "CYPhotoHeader.h"
#import "CYPhotoManager.h"

@interface CYPhotoCenter () <PHPhotoLibraryChangeObserver, UIAlertViewDelegate>

@end

@implementation CYPhotoCenter

+ (instancetype)shareCenter {
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
    [self requestPhotoLibaryAuthorizationValid];
}

#pragma mark - 完成图片选择
- (void)endPickWithImage:(UIImage *)cameraPhoto {
    if (self.handle) self.handle(@[cameraPhoto]);
}

- (void)endPick {
    if (self.handle) {
        [[CYPhotoManager manager] fetchImagesWithAssetsArray:self.selectedPhotos isOriginal:self.isOriginal completion:^(NSArray *images) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 监听图片变化代理
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // 此代理方法里的线程非主线程
    
}

#pragma mark - 权限验证
- (void)requestPhotoLibaryAuthorizationValid {
    [self requestPhotoLibaryAuthorizationValidAuthorized:nil denied:nil restricted:nil elseBlock:nil];
}

- (void)requestPhotoLibaryAuthorizationValidAuthorized:(void (^)(void))authorizedBlock denied:(void (^)(void))deniedBlock restricted:(void (^)(void))restrictedBlock elseBlock:(void(^)(void))elseBlock {
    
    [CYPhotoManager requestPhotoLibaryAuthorizationValidAuthorized:^{
//        [self reloadPhotos];
        
        if (authorizedBlock) authorizedBlock();
    } denied:^{
        if (deniedBlock) deniedBlock();
    } restricted:^{
        if (restrictedBlock) restrictedBlock();
    } elseBlock:^{
        if (elseBlock) elseBlock();
    }];
}

- (void)cameraAuthoriationValidWithHandler:(void(^)(void))handler {
    [CYPhotoManager cameraAuthoriationValidWithHandler:handler];
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
