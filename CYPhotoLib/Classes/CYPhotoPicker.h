//
//  CYPhotoPicker.h
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/11.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface CYPhotoPicker : NSObject

@property (nonatomic, assign) NSInteger selectedCount;

/*
 * 最大选择数,默认为20
 */
@property (nonatomic, assign) NSInteger maxSelectedCount;
@property (nonatomic, assign) NSInteger minSelectedCount;

/*
 * 最大预览数,默认为20
 */
@property (nonatomic, assign) NSInteger preViewCount;

/**
 弹出图片选择器

 @param sender 需要弹出图片选择器的VC,无tabbar传入当前VC.无tabbar且需要遮盖导航栏传入VC.navigationController.有tabbar需传入VC.tabbarController
 @param isSingleSel 是否单选
 @param isPushToCameraRoll 是否一进来就跳转到所有照片
 @param handle 回调
 */
- (void)showInSender:(UIViewController *)sender isSingleSel:(BOOL)isSingleSel isPushToCameraRoll:(BOOL)isPushToCameraRoll handle:(void(^)(NSArray<UIImage *> *photos, NSArray<PHAsset *> *assets))handle;

/** 清除包括已选图片的信息等 */
- (void)clearInfo;

@end
