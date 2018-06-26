//
//  CYPhotoAlbumListController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"

@class CYAlbum;

@interface CYPhotoAlbumListController : CYPhotoBaseController

@property (nonatomic, strong) NSArray<CYAlbum *> *assetCollections;  // 相册列表
@property (nonatomic, assign) BOOL isSingleSel;

@end
