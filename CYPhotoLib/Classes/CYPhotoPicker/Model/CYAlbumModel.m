//
//  CYAlbumModel.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYAlbumModel.h"

@implementation CYAlbumModel

+ (instancetype)cy_AlbumInfoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection {
    CYAlbumModel *albumInfo = [[CYAlbumModel alloc] init];
    albumInfo.albumId = collection.localIdentifier;
    albumInfo.name = collection.localizedTitle;
    albumInfo.count = result.count;
    albumInfo.result = result;
    albumInfo.coverAsset = result[0];
    albumInfo.assetCollection = collection;
    return albumInfo;
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
