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

@property (nonatomic ,strong) NSMutableArray<CYAblumInfo *> * ablumsList;

@end

@implementation CYPhotoManager

+ (instancetype)manager
{
    static CYPhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CYPhotoManager alloc] init];
        manager.ablumsList = [NSMutableArray array];
    });
    return manager;
}

/*
 * 获取所有相册
 */
- (NSArray<CYAblumInfo *> *)getAllAblums
{
    //先清空数组
    [_ablumsList removeAllObjects];
    
    //列出并加入所有智能相册 系统相册
    PHFetchResult * smartAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [self fetchCollection:smartAblums];

    
    PHFetchResult * ablums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [self fetchCollection:ablums];
    
    
    //列出列出并加入所有用户创建的相册
//    PHFetchResult * topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//    [self fetchCollection:topLevelUserCollections];
    
    // 不完美排序
//    NSArray * engNameList = @[@"Camera Roll", @"My Photo Stream", @"Recently Added", @"Selfies", @"Favorites", @"Screenshots", @"Recently Deleted", @"Bursts", @"Videos"];
//    [_ablumsList enumerateObjectsUsingBlock:^(CYAblumInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        for (NSUInteger i = 0; i<engNameList.count; i++) {
//            if ([obj.ablumName isEqualToString:engNameList[i]]) {
//                [_ablumsList exchangeObjectAtIndex:idx withObjectAtIndex:i];
//            }
//        }
//    }];
    
    [_ablumsList enumerateObjectsUsingBlock:^(CYAblumInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.ablumName isEqualToString:@"All Photos"]) {
            [_ablumsList exchangeObjectAtIndex:idx withObjectAtIndex:0];
        }
    }];
    
    return _ablumsList;
}

/*
 * 获取相册资源
 */
- (void)fetchCollection:(PHFetchResult *)obj {
    
    //如果obj是所有相册的合集
    [obj enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            
            //返回此相册的资源集合
            PHFetchResult * result = [self fetchResultInCollection:obj asending:NO];
            
            
            //如果有资源
            if (result.count) {
                
                //创建此相册的信息集
                CYAblumInfo * info = [CYAblumInfo infoFromResult:result collection:obj];
                
                //加入到数组中
                [_ablumsList addObject:info];
            }
        }
    }];
}

/*
 * 获取（指定相册）或者（所有相册）资源的合集，并按资源的创建时间进行排序 YES  倒序 NO
 */
- (PHFetchResult *)fetchResultInCollection:(PHAssetCollection *)collection asending:(BOOL)asending {
    
    PHFetchOptions * option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asending]];
    // 一个过滤器，留下的类型，图片格式
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    PHFetchResult * result;
    //获取指定相册资源合集
    if (collection) {
        
        result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
    }
    //获取所有相册资源合集
    else {
//        option.includeAssetSourceTypes = PHAssetSourceTypeNone;
        // 这里获取的是所有的资源合集?
        result = [PHAsset fetchAssetsWithOptions:option];
        
    }
    return result;
}

/** 获取所有相册图片资源 */
- (NSArray<PHAsset *> *)fetchAllAssets
{
    return [self fetchAssetsInCollection:nil asending:NO];
}

/** 获取指定相册图片资源 */
- (NSArray<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending
{
    NSMutableArray<PHAsset *> *list = [NSMutableArray array];
    
    PHFetchResult *result;
    
    if (collection) {
        result = [self fetchResultInCollection:collection asending:asending];
    }
    //获取所有相册资源
    else {
        
        result = [self fetchResultInCollection:nil asending:asending];
    }
    // 枚举添加到数组
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:obj];
    }];
    return list;
}

/** 获取资源对应的图片 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock
{
    // 请求大图界面，当切换图片时，取消上一张图片的请求，对于iCloud端的图片，可以节省流量
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = isResize ? PHImageRequestOptionsResizeModeFast : PHImageRequestOptionsResizeModeNone; //控制照片尺寸
    // option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    // 这里设置iCloud
    option.networkAccessAllowed = YES;
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
//
//        };
//    }
    
    // PHImageContentModeAspectFit ？ PHImageContentModeAspectFill ?
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        if (completeBlock) completeBlock(result, info);
    }];
}

- (void)fetchImageWithLocalIdentifiers:(NSString *)localIdentifier size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
    __weak typeof(self) weakSelf = self;
    [self fetchAssetWithLocalIdentifiers:localIdentifier completeBlock:^(PHAsset *asset) {
        
        [weakSelf fetchImageInAsset:asset size:size isResize:isResize completeBlock:completeBlock];
        
    }];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {

    CGSize imageSize;
    PHAsset *phAsset = (PHAsset *)asset;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = photoWidth * [UIScreen mainScreen].scale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);

    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
 
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
//            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
//            PHAssetImageProgressHandler dd = option.progressHandler;
//            
//            [option setProgressHandler:^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
//                
//            }];
//            
            option.networkAccessAllowed = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                resultImage = [self scaleImage:resultImage toSize:imageSize];
                if (resultImage) {
//                    resultImage = [self fixOrientation:resultImage];
                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        }
    }];
    return imageRequestID;
}

/** 根据localid获取资源对应的asset */
- (void)fetchAssetWithLocalIdentifiers:(NSString *)localIdentifier completeBlock:(void(^)(PHAsset *asset))completeBlock {
    // 需要localIdentifier
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:fetchOptions];
    PHAsset *asset = [fetchResult firstObject];
    if (completeBlock) completeBlock(asset);
}

/** 获取资源对应的原图大小 */
- (void)getImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
//    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completeBlock) completeBlock(imageData.length / 1000.0);
    }];
}

- (BOOL)isInLocalAblumWithAsset:(PHAsset *)asset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}

/** 获取资源对应的原图大小 */
- (void)getImageDataLength1:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completeBlock) completeBlock(imageData.length / 1000.0);
    }];
}

/** 获取资源对应的原图大小 */
- (void)getImageDataLength2:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
//    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completeBlock) completeBlock(imageData.length / 1000.0);
    }];
}

- (void)getImageDataWithLocalIdentifier:(NSString *)localIdentifier completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock {
    
    __weak typeof(self) weakSelf = self;
    [self fetchAssetWithLocalIdentifiers:localIdentifier completeBlock:^(PHAsset *asset) {
        [weakSelf getImageDataWithAsset:asset completeBlock:completeBlock];
    }];
}


/** 获取资源对应的原图data */
- (void)getImageDataWithAsset:(PHAsset *)asset completeBlock:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completeBlock
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    
    // 这里设置iCloud
//    option.networkAccessAllowed = YES;
//    option.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:completeBlock];
}

/** 获取资源数组对应的图片数组 */
- (void)fetchImagesWithAssetsArray:(NSMutableArray<PHAsset *> *)assetsArray isOriginal:(BOOL)isOriginal completeBlock:(void(^)(NSArray * images))completeBlock
{
    
    NSMutableArray * images = [NSMutableArray array];
    
    for (int i = 0; i < assetsArray.count; i ++) {
        
        PHAsset * asset = assetsArray[i];
        CGSize size;
        
        if (isOriginal) {
            
            //源图 -> 不压缩
            size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
            
        } else {
            
            //压缩的图 －> 以最长边为屏幕分辨率压缩
            CGFloat scale = (CGFloat)asset.pixelWidth / (CGFloat)asset.pixelHeight;
            if (scale > 1.0) {
                
                if (asset.pixelWidth < SCREEN_W) {
                    //最长边小于屏幕宽度时，采用原图
                    size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                } else {
                    //压缩
                    size = CGSizeMake(SCREEN_W, SCREEN_W / scale);
                }
                
            } else {
                
                if (asset.pixelHeight < SCREEN_H) {
                    //最长边小于屏幕高度时，采用原图
                    size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                } else {
                    //压缩
                    size = CGSizeMake(SCREEN_H * scale, SCREEN_H);
                }
                
            }
        }
        
        [self fetchImageInAsset:asset size:size isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            //当图片读取到指定尺寸时
            if (image.size.width >= size.width * OriginalRatio || image.size.height >= size.height * OriginalRatio) {
                
                [images addObject:image];
                
                //全部图片读取完毕
                if (images.count == assetsArray.count) {
                    
                    //执行block
                    if (completeBlock) completeBlock(images);
                }
            }
        }];
    }
}

@end
