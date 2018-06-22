//
//  CYPhotoManager.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoManager.h"
#import "CYPhotoHeader.h"

#define OriginalRatio 0.9

@interface CYPhotoManager ()

@end

@implementation CYPhotoManager

static CYPhotoManager *manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)manager {
    dispatch_once(&onceToken, ^{
        manager = [[CYPhotoManager alloc] init];
    });
    return manager;
}

+ (void)deallocManager {
    onceToken = 0;
    manager = nil;
}

#pragma mark - 权限验证
+ (void)requestPhotoLibaryAuthorizationValidAuthorized:(void (^)(void))authorizedBlock denied:(void (^)(void))deniedBlock restricted:(void (^)(void))restrictedBlock elseBlock:(void(^)(void))elseBlock {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 这里非主线程，选择完成后会出发相册变化代理方法
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.class requestPhotoLibaryAuthorizationValidAuthorized:authorizedBlock denied:deniedBlock restricted:restrictedBlock elseBlock:elseBlock];
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

+ (void)cameraAuthoriationValidWithHandle:(void(^)(void))handle {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        // 还未授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handle) handle();
                });
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        // 已经授权
        if (handle) handle();
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
- (void)fetchCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(CYAlbum *model))completion {
    
    PHFetchOptions *options = [self optionsAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage sortByModificationDate:NO ascending:YES];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        // 过滤空相册
        if (collection.estimatedAssetCount <= 0) continue;
        
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            // 创建此相册的信息集
            CYAlbum * model = [CYAlbum cy_AlbumInfoFromResult:fetchResult collection:collection needFetchAssets:needFetchAssets];
            if (completion) completion(model);
        }
    }
}

- (void)fetchAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(NSArray<CYAlbum *> *albumsArray))completion {
    NSMutableArray *albumsArray = [NSMutableArray array];
    
    PHFetchOptions *options = [self optionsAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage sortByModificationDate:NO ascending:YES];
    
    // 列出并加入所有智能相册 系统相册
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (result.count < 1) continue;
            
            if ([collection.localizedTitle containsString:@"Hidden"] || [collection.localizedTitle isEqualToString:@"已隐藏"]) continue;
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;

            CYAlbum *album = [CYAlbum cy_AlbumInfoFromResult:result collection:collection needFetchAssets:needFetchAssets];
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [albumsArray insertObject:album atIndex:0];
            } else {
                [albumsArray addObject:album];
            }
        }
    }
    
    if (completion) completion(albumsArray);
}


- (PHFetchOptions *)optionsAllowPickingVideo:(BOOL)isAllowPickingVideo allowPickingImage:(BOOL)isAllowPickingImage sortByModificationDate:(BOOL)isSortByModificationDate ascending:(BOOL)ascending {
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!isAllowPickingVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    if (!isAllowPickingImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    
    // 有两种排序 1:creationDate   2:modificationDate
    if (isSortByModificationDate) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    } else {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:ascending]];
    }
    
    return options;
}

- (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult completion:(void (^)(NSArray<CYAsset *> *array))completion {
    [self fetchAssetsFromFetchResult:fetchResult allowPickingVideo:NO allowPickingImage:YES completion:completion];
}

- (void)fetchAssetsFromFetchResult:(PHFetchResult *)fetchResult allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<CYAsset *> *array))completion {
    NSMutableArray *assets = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CYAsset *asset = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        
        if (asset) {
            [assets addObject:asset];
        }
    }];
    if (completion) completion(assets);
    
}

- (CYAsset *)assetModelWithAsset:(PHAsset *)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    
    PHAssetMediaType type = asset.mediaType;

    if (!allowPickingVideo && type == PHAssetMediaTypeVideo) return nil;
    if (!allowPickingImage && type == PHAssetMediaTypeImage) return nil;
 
    CYAsset *model = [CYAsset modelWithAsset:asset];
    
    return model;
}

/** 获取（指定相册）或者（所有相册）资源的合集，并按资源的创建时间进行排序 YES  倒序 NO */
- (PHFetchResult *)fetchResultInCollection:(PHAssetCollection *)collection asending:(BOOL)asending {
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asending]];
    // 一个过滤器，留下的类型，图片格式
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    PHFetchResult *result;
    // 获取指定相册资源合集
    if (collection) {
        
        result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
    }
    // 获取所有相册资源合集
    else {
        //        option.includeAssetSourceTypes = PHAssetSourceTypeNone;
        // 这里获取的是所有的资源合集?
        result = [PHAsset fetchAssetsWithOptions:options];
        
    }
    return result;
}

/** 获取所有相册图片资源 */
- (void)fetchAllAssets:(void (^)(NSArray<PHAsset *> *))completion {
    [self fetchAssetsInCollection:nil asending:NO completion:completion];
}

/** 获取指定相册图片资源 */
- (void)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending completion:(void (^)(NSArray<PHAsset *> *))completion {
    NSMutableArray<PHAsset *> *list = [NSMutableArray array];
    
    PHFetchResult *result;
    
    if (collection) {
        result = [self fetchResultInCollection:collection asending:asending];
    }
    // 获取所有相册资源
    else {
        
        result = [self fetchResultInCollection:nil asending:asending];
    }
    // 枚举添加到数组
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:obj];
    }];
    
    // 缓存
//    PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];
//    [cachingImageManager startCachingImagesForAssets:list
//                                          targetSize:PHImageManagerMaximumSize
//                                         contentMode:PHImageContentModeAspectFit
//                                             options:nil];

    if (completion) completion(list);
}

/** 根据localid获取资源对应的asset */
- (void)fetchAssetWithLocalIdentifier:(NSString *)localIdentifier completeBlock:(void(^)(PHAsset *asset))completeBlock {
    // 需要localIdentifier
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:fetchOptions];
    PHAsset *asset = [fetchResult firstObject];
    if (completeBlock) completeBlock(asset);
}

- (BOOL)isInLocalAlbumWithAsset:(PHAsset *)asset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAlbum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAlbum = imageData ? YES : NO;
    }];
    return isInLocalAlbum;
}

#pragma mark - Image相关 

/** 获取资源对应的图片 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
    // 请求大图界面，当切换图片时，取消上一张图片的请求，对于iCloud端的图片，可以节省流量
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     synchronous：指定请求是否同步执行。
     resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
     */
    option.resizeMode = isResize ? PHImageRequestOptionsResizeModeFast : PHImageRequestOptionsResizeModeNone; //控制照片尺寸
    option.deliveryMode = isResize ? PHImageRequestOptionsDeliveryModeOpportunistic : PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // PHImageRequestOptionsDeliveryModeFastFormat 超级模糊
    //
    // option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    // 这里设置iCloud
    option.networkAccessAllowed = YES;
    
    // 是否同步请求
    option.synchronous = !isResize;
        
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */

    // 下载进度监听
//    if (!isResize) {
//        option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
//            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [NSNumber numberWithDouble: progress], @"progress", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:CYPHOTOLIB_PROGRESS_NOTIFICATION object:dict];
//            
//        };
//    }
    
    // PHImageContentModeAspectFit ？ PHImageContentModeAspectFill ?
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        
        // 这里是异步的
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        if (completeBlock) completeBlock(result, info);
    }];
}

- (void)fetchImageWithLocalIdentifier:(NSString *)localIdentifier size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
    __weak typeof(self) weakSelf = self;
    [self fetchAssetWithLocalIdentifier:localIdentifier completeBlock:^(PHAsset *asset) {
        
        [weakSelf fetchImageInAsset:asset size:size isResize:isResize completeBlock:completeBlock];
        
    }];
}

- (int32_t)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:NO];
    
}

- (int32_t)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGSize imageSize;
    PHAsset *phAsset = (PHAsset *)asset;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = photoWidth * [UIScreen mainScreen].scale * 1.5;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    __block UIImage *image;
    
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            image = result;
        }
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        // 不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && result) {
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
//                resultImage = [self scaleImage:resultImage toSize:imageSize];
                if (!resultImage) {
                    resultImage = image;
                }
//                    resultImage = [self fixOrientation:resultImage];
                if (completion) completion(resultImage, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }];
        }
    }];
    return imageRequestID;
}

/** 获取资源对应的原图大小 */
- (void)fetchImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
//    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        CGImageSourceRef imageRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
//        NSDictionary *imageProperty = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageRef,0, NULL));
//        NSDictionary *ExifDictionary = [imageProperty valueForKey:(NSString*)kCGImagePropertyExifDictionary];
        
        if (completeBlock) completeBlock(imageData.length / 1000.0);
    }];
}

- (void)fetchImageDataWithLocalIdentifier:(NSString *)localIdentifier completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock {
    
    __weak typeof(self) weakSelf = self;
    [self fetchAssetWithLocalIdentifier:localIdentifier completeBlock:^(PHAsset *asset) {
        [weakSelf fetchImageDataWithAsset:asset completeBlock:completeBlock];
    }];
}

/** 获取资源对应的原图data */
- (void)fetchImageDataWithAsset:(PHAsset *)asset completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
//    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:completeBlock];
}

/** 获取资源数组对应的图片数组 */
- (void)fetchImagesWithAssetsArray:(NSArray<CYAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completeBlock:(void(^)(NSArray * images))completeBlock {
    
    NSMutableArray * images = [NSMutableArray array];
    
    NSMutableArray *assets = [NSMutableArray array];
    
    for (int i = 0; i < assetsArray.count; i++) {

        [assets addObject:assetsArray[i].asset];
    }
    
    for (int i = 0; i < assets.count; i++) {
        
        PHAsset * asset = assets[i];
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
        
        [self fetchImageInAsset:asset size:size isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            //当图片读取到指定尺寸时
            if (image.size.width >= size.width * OriginalRatio || image.size.height >= size.height * OriginalRatio) {
                
                [images addObject:image];
                
                //全部图片读取完毕
                if (images.count == assets.count) {
                    
                    //执行block
                    if (completeBlock) completeBlock(images);
                }
            }
        }];
    }
}

@end
