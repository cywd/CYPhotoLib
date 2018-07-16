//
//  CYPhotoAlbumListController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"

@interface CYPhotoAlbumsController : CYPhotoBaseController

@property (nonatomic, assign) BOOL isSingleSel;
@property (nonatomic, assign) BOOL sortByModificationDate;
@property (nonatomic, assign) BOOL ascending;
@property (nonatomic, assign) NSInteger columnNumber;

@end