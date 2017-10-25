//
//  CYPhotoBrowserController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"
@class PHAssetCollection;

@class CYAblumModel;

@interface CYPhotoBrowserController : CYPhotoBaseController

@property (nonatomic, strong) CYAblumModel *info;

@property (nonatomic, copy) NSString * collectionTitle;

@property (nonatomic, strong) PHAssetCollection * assetCollection;

@property (nonatomic, assign) BOOL isSingleSel;

@end
