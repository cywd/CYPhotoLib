//
//  CYPhotoManager.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//
// 负责管理与Photo 相关的内容

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CYPhotoAlbum;
@class CYPhotoAsset;


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
+ (void)cameraAuthoriationValidWithHandler:(void(^)(void))handler;

#pragma mark - Album 相关
/**
 拿到相册model

 @param allowPickingVideo 是否允许选择video
 @param allowPickingImage 是否允许选择image
 @param completion 回调相册model
 */
- (void)fetchCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending completion:(void (^)(CYPhotoAlbum *model))completion;
/**
 获取所有相册model的数组

 @param allowPickingVideo 是否允许选择video
 @param allowPickingImage 是否允许选择image
 @param completion 回调所有相册model的数组
 */
- (void)fetchAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending completion:(void (^)(NSArray<CYPhotoAlbum *> *albumsArray))completion;

#pragma mark - Asset 相关
/**
 根据result取出CYAsset集合

 @param fetchResult PHFetchResult
 @param completion 回调
 */
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult completion:(void (^)(NSArray<CYPhotoAsset *> *array))completion;

/**
 根据result取出CYAsset集合

 @param fetchResult PHFetchResult
 @param allowPickingVideo 是否允许选择video
 @param allowPickingImage 是否允许选择image
 @param completion 回调
 */
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<CYPhotoAsset *> *array))completion;

/**
 根据localIdentifier获取资源对应的asset

 @param localIdentifier PHAsset的id
 @param completion 回调
 */
- (void)fetchAssetWithLocalIdentifier:(NSString *)localIdentifier completion:(void(^)(PHAsset *asset))completion;

/**
 获取封面Asset

 @param album album
 @param completion 回调
 */
- (void)fetchCoverAssetWithAlbum:(CYPhotoAlbum *)album completion:(void (^)(CYPhotoAsset *asset))completion;

/**
 获取封面image

 @param album album
 @param completion 回调
 */
- (void)fetchCoverImageWithAlbum:(CYPhotoAlbum *)album completion:(void (^)(UIImage *image))completion;


/**
 本地是否有这个Asset

 @param asset PHasset
 @return 本地是否有
 */
- (BOOL)isLocalInAlbumWithAsset:(PHAsset *)asset;

#pragma mark - Image 相关

- (void)fetchImagesWithAssetsArray:(NSArray<CYPhotoAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completion:(void(^)(NSArray * images))completion;

/**
 根据Asset获取图片（不允许网络）

 @param asset PHAsset
 @param photoWidth 宽
 @param completion 回调
 @return 一个标识符
 */
- (int32_t)fetchImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion;
/**
 获取图片，可查看进度

 @param asset PHAsset
 @param photoWidth 宽
 @param completion 回调
 @param progressHandler 进度回调
 @param networkAccessAllowed 是否允许网络
 @return 一个int32_t标识符
 */
- (int32_t)fetchImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/**
 根据asset 获取原图 （默认联网请求，同步）

 @param asset PHAsset
 @param completion 回调
 */
- (void)fetchOriginalImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;


/**
 根据asset 获取原图

 @param asset PHAsset
 @param networkAccessAllowed 是否允许网络
 @param synchronous 是否同步请求
 @param completion 回调
 */
- (void)fetchOriginalImageWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed synchronous:(BOOL)synchronous completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

/** 获取资源对应的图片 */
//- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completion:(void(^)(UIImage * image, NSDictionary * info))completion;
/** 通过localIdentifier获取资源对应的image */
//- (void)fetchImageWithLocalIdentifier:(NSString *)localIdentifier size:(CGSize)size isResize:(BOOL)isResize completion:(void(^)(UIImage * image, NSDictionary * info))completion;
///** 获取资源数组对应的图片数组 */
//- (void)fetchImagesWithAssetsArray:(NSArray<CYAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completion:(void(^)(NSArray * images))completion;


#pragma mark - ImageData 相关
/**
 根据asset获取原图data

 @param asset PHAsset
 @param completion 回调data，info，是否是缩略图
 */
- (void)fetchOriginalImageDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion;

/**
 根据id获取原图data

 @param localIdentifier id
 @param completion 回调data，info，是否是缩略图
 */
- (void)fetchOriginalImageDataWithLocalIdentifier:(NSString *)localIdentifier completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion;

/**
 根据asset获取原图data的大小

 @param asset PHAsset
 @param completion 回调
 */
- (void)fetchImageDataBytesWithAsset:(PHAsset *)asset completion:(void(^)(CGFloat length))completion;

@end
