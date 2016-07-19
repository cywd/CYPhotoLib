//
//  CYAblumInfo.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CYAblumInfo : NSObject

@property (nonatomic, copy) NSString * ablumName; //相册名字

@property (nonatomic, assign) NSInteger count; //总照片数

@property (nonatomic, strong) PHAssetCollection * assetCollection; //相册

@property (nonatomic, strong) PHAsset * coverAsset; //封面

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection;

@end
