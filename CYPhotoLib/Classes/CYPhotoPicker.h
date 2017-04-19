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

/*
 * 最大选择数,默认为20
 */
@property (nonatomic, assign) NSInteger selectedCount;

@property (nonatomic, assign) NSInteger maxSelectedCount;
@property (nonatomic, assign) NSInteger minSelectedCount;

/*
 * 最大预览数,默认为20
 */
@property (nonatomic, assign) NSInteger preViewCount;

/**
 *  弹出图片选择器
 *
 *  @param sender
 sender:需要弹出图片选择器的VC
 sender:无tabbar传入当前VC
 sender:无tabbar且需要遮盖导航栏传入VC.navigationController
 sender:有tabbar需传入VC.tabbarController
 *
 *  @param handle 回调（图片数组）
 */

- (void)showInSender:(UIViewController *)sender isSingleSel:(BOOL)isSingleSel handle:(void(^)(NSArray<UIImage *> *photos, NSArray<PHAsset *> *assets))handle;


/** 清除包括已选图片的信息等 */
- (void)clearInfo;

@end
