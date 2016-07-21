//
//  CYPhotoPreviewerController.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"

@class PHAsset;

@interface CYPhotoPreviewerController : CYPhotoBaseController

@property (nonatomic, strong) PHAsset * selectedAsset; //初始显示的图片
@property (nonatomic, strong) NSArray * previewPhotos;
@property (nonatomic, assign) BOOL isPreviewSelectedPhotos;

@property (nonatomic, copy) void(^backBlock)();
@property (nonatomic, copy) void(^doneBlock)();

@end
