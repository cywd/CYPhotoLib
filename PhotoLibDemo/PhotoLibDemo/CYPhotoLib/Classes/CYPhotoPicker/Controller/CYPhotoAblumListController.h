//
//  CYPhotoAblumListController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"

@interface CYPhotoAblumListController : CYPhotoBaseController

@property (nonatomic, strong) NSArray * assetCollections;   //相册列表

@property (nonatomic, assign) BOOL isSingleSel;

@end
