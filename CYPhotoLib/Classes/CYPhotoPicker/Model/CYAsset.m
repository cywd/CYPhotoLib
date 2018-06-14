//
//  CYAsset.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/10/25.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYAsset.h"

@implementation CYAsset

+ (instancetype)modelWithAsset:(PHAsset *)asset {
    CYAsset *model = [[CYAsset alloc] init];
    model.asset = asset;
    return model;
}

@end
