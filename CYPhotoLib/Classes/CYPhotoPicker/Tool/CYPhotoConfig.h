//
//  CYPhotoConfig.h
//  CYPhotoLib
//
//  Created by Cyrill on 2017/4/26.
//  Copyright © 2017年 Cyrill. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CYPhotoConfig : NSObject

#pragma mark - 相册配置相关

/**
 是否允许旋转横屏
 */
@property (nonatomic, assign, getter=isShouldAutorotate) BOOL shouldAutorotate;

// CY-TODO: 下一步，支持可以选择视频，以及可以预览图片和视频
/**
 是否允许选择视频
 */
@property (nonatomic, assign, readonly, getter=isAllowPickingVideo) BOOL allowPickingVideo;
/**
 是否允许选择图片
 */
@property (nonatomic, assign, getter=isAllowPickingImage) BOOL allowPickingImage;
/**
 是否跳转到相机胶卷
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

#pragma mark - 相册UI相关
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
 最小不可选图片数据大小
 */
@property (nonatomic) CGFloat minDisabledDataLength;
/**
 最大不可选图片数据大小
 */
@property (nonatomic) CGFloat maxDisabledDataLength;
/**
 最小显示警告图片数据大小
 */
@property (nonatomic) CGFloat minWarningDataLength;
/**
 最大显示警告图片数据大小
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

+ (instancetype)defaultConfig;

@end
