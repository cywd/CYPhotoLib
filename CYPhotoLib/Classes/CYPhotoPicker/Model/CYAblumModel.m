//
//  CYAblumModel.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYAblumModel.h"

@implementation CYAblumModel

+ (instancetype)cy_AblumInfoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection {
    CYAblumModel *ablumInfo = [[CYAblumModel alloc] init];
    ablumInfo.ablumId = collection.localIdentifier;
    ablumInfo.name = collection.localizedTitle;
    ablumInfo.count = result.count;
    ablumInfo.result = result;
    ablumInfo.coverAsset = result[0];
    ablumInfo.assetCollection = collection;
    return ablumInfo;
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
