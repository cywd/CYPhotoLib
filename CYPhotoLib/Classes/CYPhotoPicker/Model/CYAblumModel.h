//
//  CYAblumModel.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CYAblumModel : NSObject

@property (nonatomic, copy) NSString *ablumId;
/** 相册名字 */
@property (nonatomic, copy) NSString *name;
/** 总照片数 */
@property (nonatomic, assign) NSInteger count;
/** 相册 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *result;
/** 封面 */
@property (nonatomic, strong) PHAsset *coverAsset;

+ (instancetype)cy_AblumInfoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection;

- (PHAsset *)assetOfIndex:(NSInteger)index;
- (void)stopICloudActivity;

@end
