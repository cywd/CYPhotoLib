//
//  CYPhotoConfig.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/4/26.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYPhotoConfig.h"

@implementation CYPhotoConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allowPickingVideo = YES;
        _allowPickingImage = YES;
        _pushToCameraRoll = YES;
        _singlePick = NO;
        _sortByModificationDate = NO;
        _ascending = NO;
        _maxSelectedCount = 20;
        _minSelectedCount = 1;
        _columnNumber = 4;
        _minimumLineSpacing = 5;
        _minimumInteritemSpacing = 5;
        _showCountFooter = YES;
        
    }
    return self;
}

@end
