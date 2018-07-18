//
//  CYAlbum.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAlbum.h"
#import "CYPhotoManager.h"

@implementation CYPhotoAlbum

+ (instancetype)cy_AlbumInfoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection needFetchAssets:(BOOL)needFetchAssets {
    CYPhotoAlbum *albumInfo = [[CYPhotoAlbum alloc] init];
    albumInfo.albumId = collection.localIdentifier;
    albumInfo.name = collection.localizedTitle;
    albumInfo.count = result.count;
    [albumInfo setResult:result needFetchAssets:needFetchAssets];
    albumInfo.coverAsset = result[0];
    albumInfo.assetCollection = collection;
    return albumInfo;
}

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    
    if (needFetchAssets) {
        [[CYPhotoManager manager] fetchAssetsFromFetchResult:result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<CYPhotoAsset *> *array) {
            self.assets = array;
        }];
    }
}

- (PHAsset *)assetOfIndex:(NSInteger)index {
    if (index >= 0 && index <= self.count) {
        return self.result[index];
    } else {
        return nil;
    }
}

- (void)stopICloudActivity {
    // TODO: cy pass
    // <#code#>
}

@end
