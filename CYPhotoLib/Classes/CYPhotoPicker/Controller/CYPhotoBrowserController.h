//
//  CYPhotoBrowserController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"
@class PHAssetCollection;
@class CYAlbum;
@class CYAsset;

@interface CYPhotoBrowserController : CYPhotoBaseController

@property (nonatomic, strong) CYAlbum *info;
@property (nonatomic, copy) NSString * collectionTitle;
@property (nonatomic, strong) NSArray<CYAsset *> *assets;
@property (nonatomic, assign) BOOL isSingleSel;

@end
