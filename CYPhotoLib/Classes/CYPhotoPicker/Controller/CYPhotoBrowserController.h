//
//  CYPhotoBrowserController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"

@class CYAsset;
@class CYAlbum;

@interface CYPhotoBrowserController : CYPhotoBaseController

@property (nonatomic, strong) CYAlbum *album;
@property (nonatomic, copy) NSString * collectionTitle;
@property (nonatomic, strong) NSArray<CYAsset *> *assets;
@property (nonatomic, assign) BOOL isSingleSel;

@end
