//
//  CYAblumInfo.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYAblumInfo.h"

@implementation CYAblumInfo

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection
{
    CYAblumInfo *ablumInfo = [[CYAblumInfo alloc] init];
    ablumInfo.ablumName = collection.localizedTitle;
    ablumInfo.count = result.count;
    ablumInfo.coverAsset = result[0];
    ablumInfo.assetCollection = collection;
    return ablumInfo;
}

@end
