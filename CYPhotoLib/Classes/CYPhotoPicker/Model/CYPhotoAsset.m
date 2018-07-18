//
//  CYAsset.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/10/25.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYPhotoAsset.h"
#import "CYPhotoManager.h"

@implementation CYPhotoAsset

+ (instancetype)modelWithAsset:(PHAsset *)asset {
    CYPhotoAsset *model = [[CYPhotoAsset alloc] init];
    model.asset = asset;
    return model;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
//    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
//     dispatch_async(queue, ^{
//        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
//        long long originFileSize = [[resource valueForKey:@"fileSize"] longLongValue];
//        int fileSize = (int)originFileSize;
//         NSLog(@"%@", @(fileSize));
//     });
    
}

@end
