//
//  CYPhotoManager.m
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoManager.h"
#import "CYPhotoAlbum.h"
#import "CYPhotoAsset.h"
#import "CYPhotoHeader.h"
#import "NSBundle+CYPhotoLib.h"

#define OriginalRatio 0.9

@interface CYPhotoManager ()

@end

@implementation CYPhotoManager

#pragma mark - 权限验证
+ (void)requestPhotoLibaryAuthorizationValidAuthorized:(void (^)(void))authorizedBlock denied:(void (^)(void))deniedBlock restricted:(void (^)(void))restrictedBlock elseBlock:(void(^)(void))elseBlock {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 这里非主线程，选择完成后会出发相册变化代理方法
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestPhotoLibaryAuthorizationValidAuthorized:authorizedBlock denied:deniedBlock restricted:restrictedBlock elseBlock:elseBlock];
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        // 已经授权
        if (authorizedBlock) authorizedBlock();
    } else if (status == PHAuthorizationStatusDenied) {
        NSLog(@"PHAuthorizationStatusDenied - 用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
        if (deniedBlock) deniedBlock();
    } else if (status == PHAuthorizationStatusRestricted) {
        NSLog(@"PHAuthorizationStatusRestricted - 家长控制,不允许访问");
        if (restrictedBlock) restrictedBlock();
    } else {
        if (elseBlock) elseBlock();
    }
}

+ (void)cameraAuthoriationValidWithHandler:(void(^)(void))handler {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        // 还未授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) handler();
                });
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        // 已经授权
        if (handler) handler();
    } else if (status == AVAuthorizationStatusRestricted) {
        // 家长模式
        NSLog(@"PHAuthorizationStatusRestricted - 家长控制,不允许访问");
        
    } else if (status == AVAuthorizationStatusDenied) {
        // 用户拒绝
        NSLog(@"PHAuthorizationStatusDenied - 用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
    } else {
        
    }
}

/*
 enum PHAssetCollectionType : Int {
 case Album //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
 case SmartAlbum //经由相机得来的相册
 case Moment //Photos 为我们自动生成的时间分组的相册
 }
 
 enum PHAssetCollectionSubtype : Int {
 case AlbumRegular //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
 case AlbumSyncedEvent //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
 case AlbumSyncedFaces //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
 case AlbumSyncedAlbum //做了 AlbumSyncedEvent 应该做的事
 case AlbumImported //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
 case AlbumMyPhotoStream //用户的 iCloud 照片流
 case AlbumCloudShared //用户使用 iCloud 共享的相册
 case SmartAlbumGeneric //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
 case SmartAlbumPanoramas //相机拍摄的全景照片
 case SmartAlbumVideos //相机拍摄的视频
 case SmartAlbumFavorites //收藏文件夹
 case SmartAlbumTimelapses //延时视频文件夹，同时也会出现在视频文件夹中
 case SmartAlbumAllHidden //包含隐藏照片或视频的文件夹
 case SmartAlbumRecentlyAdded //相机近期拍摄的照片或视频
 case SmartAlbumBursts //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
 case SmartAlbumSlomoVideos //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。不过我的 iPad mini 不支持，没法验证。
 case SmartAlbumUserLibrary //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
 case Any //包含所有类型
 }
 */
#pragma mark - Album相关
+ (void)fetchCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending completion:(void (^)(CYPhotoAlbum *model))completion {
    __block CYPhotoAlbum *model;
    PHFetchOptions *options = [self optionsAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage sortByModificationDate:isSortByModificationDate ascending:ascending];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        @autoreleasepool {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            if ([self isCameraRollAlbum:collection]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                model = [CYPhotoAlbum cy_AlbumInfoFromResult:fetchResult collection:collection needFetchAssets:needFetchAssets];
                if (completion) completion(model);
                break;
            }
        }
    }
}

+ (void)fetchAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending completion:(void (^)(NSArray<CYPhotoAlbum *> *albumsArray))completion {
    NSMutableArray *albumsArray = [NSMutableArray array];
    
    PHFetchOptions *options = [self optionsAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage sortByModificationDate:isSortByModificationDate ascending:ascending];
    
    // 列出并加入所有智能相册 系统相册
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            @autoreleasepool {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                // 过滤空相册
                if (collection.estimatedAssetCount <= 0 && ![self isCameraRollAlbum:collection]) continue;
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                if (result.count < 1 && ![self isCameraRollAlbum:collection]) continue;
                
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
                if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
                
                CYPhotoAlbum *album = [CYPhotoAlbum cy_AlbumInfoFromResult:result collection:collection needFetchAssets:needFetchAssets];
                if ([self isCameraRollAlbum:collection]) {
                    [albumsArray insertObject:album atIndex:0];
                } else {
                    [albumsArray addObject:album];
                }
            }
        }
    }
    
    if (completion) completion(albumsArray);
}

#pragma mark - Asset

+ (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult completion:(void (^)(NSArray<CYPhotoAsset *> *array))completion {
    [self fetchAssetsFromFetchResult:fetchResult allowPickingVideo:NO allowPickingImage:YES completion:completion];
}

+ (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<CYPhotoAsset *> *array))completion {
    NSMutableArray *assets = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CYPhotoAsset *asset = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (asset) {
            [assets addObject:asset];
        }
    }];
    if (completion) completion(assets);
}

+ (CYPhotoAsset *)assetModelWithAsset:(PHAsset *)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    
    PHAssetMediaType type = asset.mediaType;

    if (!allowPickingVideo && type == PHAssetMediaTypeVideo) return nil;
    if (!allowPickingImage && type == PHAssetMediaTypeImage) return nil;
 
    CYPhotoAsset *model = [CYPhotoAsset modelWithAsset:asset];
    
    return model;
}

/** 根据localid获取资源对应的asset */
+ (void)fetchAssetWithLocalIdentifier:(NSString *)localIdentifier completion:(void(^)(PHAsset *asset))completion {
    // 需要localIdentifier
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:fetchOptions];
    PHAsset *asset = [fetchResult firstObject];
    if (completion) completion(asset);
}

+ (BOOL)isLocalInAlbumWithAsset:(PHAsset *)asset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAlbum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAlbum = imageData ? YES : NO;
    }];
    return isInLocalAlbum;
}

+ (void)fetchCoverAssetWithAlbum:(CYPhotoAlbum *)album completion:(void (^)(CYPhotoAsset *asset))completion {
    id obj = [album.result lastObject];
    CYPhotoAsset *tmp_asset = [self assetModelWithAsset:obj allowPickingVideo:NO allowPickingImage:YES];
    if (completion) completion(tmp_asset);
}

+ (void)fetchCoverImageWithAlbum:(CYPhotoAlbum *)album completion:(void (^)(UIImage *image))completion {
    id asset = [album.result lastObject];
    [self fetchImageWithAsset:asset photoWidth:80 completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(image);
    }];
}

#pragma mark - Image相关

/** 获取资源数组对应的图片数组 */
+ (void)fetchImagesWithAssetsArray:(NSArray<CYPhotoAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completion:(void(^)(NSArray * images))completion {
    
    NSMutableArray * images = [NSMutableArray array];
    
    for (int i = 0; i < assetsArray.count; i++) {
        @autoreleasepool {
            
            PHAsset * asset = assetsArray[i].asset;
            CGSize size;
            
            if (isOriginal) {
                
                // 源图 -> 不压缩
                size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                
            } else {
                
                // 压缩的图 －> 以最长边为屏幕分辨率压缩
                CGFloat scale = (CGFloat)asset.pixelWidth / (CGFloat)asset.pixelHeight;
                if (scale > 1.0) {
                    
                    if (asset.pixelWidth < CYPHOTOLIB_SCREEN_W) {
                        // 最长边小于屏幕宽度时，采用原图
                        size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                    } else {
                        // 压缩
                        size = CGSizeMake(CYPHOTOLIB_SCREEN_W, CYPHOTOLIB_SCREEN_W / scale);
                    }
                    
                } else {
                    
                    if (asset.pixelHeight < CYPHOTOLIB_SCREEN_H) {
                        // 最长边小于屏幕高度时，采用原图
                        size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                    } else {
                        // 压缩
                        size = CGSizeMake(CYPHOTOLIB_SCREEN_H * scale, CYPHOTOLIB_SCREEN_H);
                    }
                    
                }
            }
            
            if (isOriginal) {
                [self fetchOriginalImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
                    [images addObject:image];
                    if (images.count == assetsArray.count) {
                        //执行block
                        
                        if (completion) completion(images);
                    }
                }];
            } else {
                [self fetchImageWithAsset:asset photoWidth:size.width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
                    [images addObject:image];
                    if (images.count == assetsArray.count) {
                        //执行block
                        if (completion) completion(images);
                    }
                } progressHandler:nil networkAccessAllowed:NO synchronous:YES];
            }
        }
    }
}


+ (int32_t)fetchImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion {
    return [self fetchImageWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:NO];
}

+ (int32_t)fetchImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self fetchImageWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed synchronous:NO];
}

+ (int32_t)fetchImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed synchronous:(BOOL)synchronous {
    CGSize imageSize;
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = photoWidth * [UIScreen mainScreen].scale;
    // 超宽图片
    if (aspectRatio > 1.8) {
        pixelWidth = pixelWidth * aspectRatio;
    }
    // 超高图片
    if (aspectRatio < 0.2) {
        pixelWidth = pixelWidth * 0.5;
    }
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    __block UIImage *image;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    /**
     synchronous：指定请求是否同步执行。
     resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
     */
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = synchronous;
    
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            image = result;
        }
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        // 不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result &&  networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%f", progress);
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                if (!resultImage) {
                    resultImage = image;
                }
                resultImage = [self fixOrientation:resultImage];
                if (completion) completion(resultImage, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }];
        }
    }];
    return imageRequestID;
}

/// 获取原图
+ (void)fetchOriginalImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image, NSDictionary *info, BOOL isDegraded))completion {
    [self fetchOriginalImageWithAsset:asset networkAccessAllowed:YES synchronous:YES completion:completion];
}

+ (void)fetchOriginalImageWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed synchronous:(BOOL)synchronous completion:(void (^)(UIImage *image, NSDictionary *info, BOOL isDegraded))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    /**
     synchronous：指定请求是否同步执行。
     resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
     */
    options.networkAccessAllowed = networkAccessAllowed;
    options.synchronous = synchronous;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
//            result = [self fixOrientation:result];
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(result, info, isDegraded);
        }
    }];
}

#pragma mark - image data
/// 获取原图data
+ (void)fetchOriginalImageDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData, info, NO);
        }
    }];
}

/// 根据id获取原图data
+ (void)fetchOriginalImageDataWithLocalIdentifier:(NSString *)localIdentifier completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion {
    
    __weak typeof(self) weakSelf = self;
    [self fetchAssetWithLocalIdentifier:localIdentifier completion:^(PHAsset *asset) {
        [weakSelf fetchOriginalImageDataWithAsset:asset completion:completion];
    }];
}


/** 获取资源对应的原图大小 */
+ (PHImageRequestID)fetchImageDataBytesWithAsset:(PHAsset *)asset completion:(void (^)(CGFloat length))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.version = PHImageRequestOptionsVersionCurrent;
    @autoreleasepool {
        return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSUInteger length = 0.0;
            if (imageData) {
                length = imageData.length;
            }
            if (completion) completion(length);
        }];
    }
}

+ (CGSize)photoSizeWithAsset:(PHAsset *)asset {
    return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
}

+ (BOOL)isCameraRollAlbum:(id)metadata {
    if ([metadata isKindOfClass:[PHAssetCollection class]]) {
        NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (versionStr.length <= 1) {
            versionStr = [versionStr stringByAppendingString:@"00"];
        } else if (versionStr.length <= 2) {
            versionStr = [versionStr stringByAppendingString:@"0"];
        }
        CGFloat version = versionStr.floatValue;
        // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
        if (version >= 800 && version <= 802) {
            return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
        } else {
            return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
        }
    }
    
    return NO;
}

#pragma mark - private
+ (PHFetchOptions *)optionsAllowPickingVideo:(BOOL)isAllowPickingVideo allowPickingImage:(BOOL)isAllowPickingImage sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending {
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!isAllowPickingVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    if (!isAllowPickingImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    
    // 有两种排序 1:creationDate   2:modificationDate
    if (isSortByModificationDate) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:ascending]];
    } else {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    }
    
    return options;
}

/// 修正图片转向
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
