//
//  CYAsset.h
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/10/25.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;

/**
 按照给定标准所处于的类型

 - CYAssetMassTypeLarge: 过大
 - CYAssetMassTypeNormal: 正常
 - CYAssetMassTypeSmall: 过小
 - CYAssetMassTypeLowDpi: 低分辨率
 - CYAssetMassTypeFreakRatio: 不符合的比例
 */
typedef NS_ENUM(NSUInteger, CYAssetMassType) {
    CYAssetMassTypeTooLarge,
    CYAssetMassTypeLarge,
    CYAssetMassTypeNormal,
    CYAssetMassTypeTooSmall,
    CYAssetMassTypeSmall,
    CYAssetMassTypeLowDpi,
    CYAssetMassTypeFreakRatio,  //
    CYAssetMassTypeUnknow,
};

/**
 显示的状态

 - CYAssetMassStatusNormal: 正常
 - CYAssetMassStatusWarning: 警告状态
 - CYAssetMassStatusDisabled: 不可用状态
 */
typedef NS_ENUM(NSUInteger, CYAssetMassStatus) {
    CYAssetMassStatusNormal,
    CYAssetMassStatusWarning,
    CYAssetMassStatusDisabled,
};

/** 自定义Asset */
@interface CYAsset : NSObject

/** 原始asset */
@property (nonatomic, strong) PHAsset *asset;
/** 按照给定标准所处于的类型 */
@property (nonatomic, assign) CYAssetMassType massType;
/** 显示的状态 */
@property (nonatomic, assign) CYAssetMassStatus massStatus;

+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end
