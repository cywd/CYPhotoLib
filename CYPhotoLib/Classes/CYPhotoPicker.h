//
//  CYPhotoPicker.h
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class CYPhotoAsset;
@class CYPhotoConfig;

@interface CYPhotoPicker : NSObject

#pragma mark - config

/**
 是否允许旋转横屏
 */
@property (nonatomic, assign, getter=isShouldAutorotate) BOOL shouldAutorotate;

/**
 是否允许选择视频
 */
//@property (nonatomic, assign, getter=isAllowPickingVideo) BOOL allowPickingVideo;
/**
 是否允许选择图片
 */
@property (nonatomic, assign, getter=isAllowPickingImage) BOOL allowPickingImage;
/**
 是否跳转到相机胶卷, 默认YES
 */
@property (nonatomic, assign, getter=isPushToCameraRoll) BOOL pushToCameraRoll;
/**
 是否是单选
 */
@property (nonatomic, assign, getter=isSinglePick) BOOL singlePick;
/**
 按照修改日期排序
 */
@property (nonatomic, assign, getter=isSortByModificationDate) BOOL sortByModificationDate;
/**
 正叙倒叙
 */
@property (nonatomic, assign, getter=isAscending) BOOL ascending;
/**
 默认图片宽
 */
@property (nonatomic, assign) CGFloat defaultImageWidth;
/**
 最大可选数量
 */
@property (nonatomic, assign) NSInteger maxSelectedCount;
/**
 最小可选数量
 */
@property (nonatomic, assign) NSInteger minSelectedCount;
/**
 边缘间距
 */
@property (nonatomic, assign) UIEdgeInsets edgeInset;
/**
 列数
 */
@property (nonatomic, assign) NSInteger columnNumber;
/**
 最小横向方向间隔
 */
@property (nonatomic) CGFloat minimumLineSpacing;
/**
 最小竖直方向间隔
 */
@property (nonatomic) CGFloat minimumInteritemSpacing;


/*
 minDisabledDataLength must smaller than minWarningDataLength
 maxDisabledDataLength must bigger than maxWarningDataLength
 */

/**
 最小不可选图片数据大小 kb
 */
@property (nonatomic) CGFloat minDisabledDataLength;
/**
 最大不可选图片数据大小 kb
 */
@property (nonatomic) CGFloat maxDisabledDataLength;
/**
 最小显示警告图片数据大小 kb
 */
@property (nonatomic) CGFloat minWarningDataLength;
/**
 最大显示警告图片数据大小 kb
 */
//@property (nonatomic) CGFloat maxWarningDataLength;


/*
 minDisabledSize must smaller than minWarningSize
 maxDisabledSize must bigger than maxWarningSize
 */


///**
// 最小不可选Size
// */
//@property (nonatomic) CGSize minDisabledSize;
///**
// 最大不可选Size
// */
//@property (nonatomic) CGSize maxDisabledSize;
///**
// 最小显示警告Size
// */
//@property (nonatomic) CGSize minWarningSize;
///**
// 最大显示警告Size
// */
//@property (nonatomic) CGSize maxWarningSize;

/**
 不可选宽高比
 the aspect ratio.
 `width * 1.0 / height`
 */
@property (nonatomic) CGFloat disabledAspectRatio;
/**
 显示警告宽高比
 the aspect ratio.
 `width * 1.0 / height`
 */
@property (nonatomic) CGFloat warningAspectRatio;

@property (nonatomic, assign, getter=isShowCountFooter) BOOL showCountFooter;

#pragma mark - 其他
@property (nonatomic, assign) NSInteger selectedCount;

/**
 弹出图片选择器

 @param sender 需要弹出图片选择器的VC,无tabbar传入当前VC.无tabbar且需要遮盖导航栏传入VC.navigationController.有tabbar需传入VC.tabbarController
 @param handler 回调
 */
- (void)showInSender:(__kindof UIViewController *)sender handler:(void(^)(NSArray<PHAsset *> *assets))handler;

/**
 弹出图片选择器（配置文件）

 @param sender 需要弹出图片选择器的VC,无tabbar传入当前VC.无tabbar且需要遮盖导航栏传入VC.navigationController.有tabbar需传入VC.tabbarController
 @param config 配置文件
 @param handler 回调
 */
- (void)showInSender:(__kindof UIViewController *)sender config:(CYPhotoConfig *)config handler:(void(^)(NSArray<PHAsset *> *assets))handler;


/** 清除包括已选图片的信息等 */
- (void)clearInfo;

@end
