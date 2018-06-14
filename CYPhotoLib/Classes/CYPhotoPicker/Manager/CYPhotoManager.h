//
//  CYPhotoManager.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//
// 负责管理与Photo 相关的内容

#import <Foundation/Foundation.h>
#import "CYAlbum.h"
#import "CYAsset.h"

@interface CYPhotoManager : NSObject

/** 单例 */
+ (instancetype)manager;
/** dealloc 单例 */
+ (void)deallocManager;

#pragma mark - 权限相关
/**
 去请求照片库权限

 @param authorizedBlock 已经授权
 @param deniedBlock 用户拒绝
 @param restrictedBlock 家长控制
 @param elseBlock 其他
 */
+ (void)requestPhotoLibaryAuthorizationValidAuthorized:(void (^)(void))authorizedBlock denied:(void (^)(void))deniedBlock restricted:(void (^)(void))restrictedBlock elseBlock:(void(^)(void))elseBlock;

/**
 去请求相机权限

 @param handle 回调
 */
+ (void)cameraAuthoriationValidWithHandle:(void(^)(void))handle;

#pragma mark - Album 相关
/**
 拿到相册model

 @param allowPickingVideo 是否允许选择video
 @param allowPickingImage 是否允许选择image
 @param completion 回调相册model
 */
- (void)fetchCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(CYAlbum *model))completion;
/**
 获取所有相册model的数组

 @param allowPickingVideo 是否允许选择video
 @param allowPickingImage 是否允许选择image
 @param completion 回调所有相册model的数组
 */
- (void)fetchAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<CYAlbum *> *albumsArray))completion;

#pragma mark - Asset 相关
/** 获取所有相册图片资源 */
- (void)fetchAllAssets:(void (^)(NSArray<PHAsset *> *))completion;
/** 获取指定相册图片资源 */
- (void)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending completion:(void (^)(NSArray<PHAsset *> *))completion;
/** 根据localIdentifier获取资源对应的asset */
- (void)fetchAssetWithLocalIdentifier:(NSString *)localIdentifier completeBlock:(void(^)(PHAsset *asset))completeBlock;
/** 本地是否有这个Asset */
- (BOOL)isInLocalAlbumWithAsset:(PHAsset *)asset;

- (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<CYAsset *> *array))completion;

#pragma mark - Image 相关
/** 获取资源对应的图片 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;
/** 通过localIdentifier获取资源对应的image */
- (void)fetchImageWithLocalIdentifier:(NSString *)localIdentifier size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;
/** 获取资源数组对应的图片数组 */
- (void)fetchImagesWithAssetsArray:(NSMutableArray<PHAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completeBlock:(void(^)(NSArray * images))completeBlock;

#pragma mark - ImageData 相关
/** 通过localIdentifier获取资源对应的原图data */
- (void)fetchImageDataWithLocalIdentifier:(NSString *)localIdentifier completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock;
/** 获取资源对应的原图大小 */
- (void)fetchImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock;
/** 获取资源对应的原图data */
- (void)fetchImageDataWithAsset:(PHAsset *)asset completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock;


- (int32_t)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

@end
