//
//  CYAlbumM.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class CYPhotoAsset;

/** 相册model */
@interface CYPhotoAlbum : NSObject

/** 相册id */
@property (nonatomic, copy) NSString *albumId;
/** 相册名字 */
@property (nonatomic, copy) NSString *name;
/** 总照片数 */
@property (nonatomic, assign) NSInteger count;
/** 相册 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *result;
/** 封面 */
@property (nonatomic, strong) PHAsset *coverAsset;

@property (nonatomic, strong) NSArray<CYPhotoAsset *> *assets;

+ (instancetype)cy_AlbumInfoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection needFetchAssets:(BOOL)needFetchAssets;

- (PHAsset *)assetOfIndex:(NSInteger)index;
- (void)stopICloudActivity;

@end
