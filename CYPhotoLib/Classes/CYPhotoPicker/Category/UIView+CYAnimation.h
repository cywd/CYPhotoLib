//
//  UIView+CYAnimation.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CYAnimation)

/**
 *  从底部升起出现
 */
- (void)showFromBottom;

/**
 *  消失降到底部
 */
- (void)dismissToBottomWithCompleteBlock:(void(^)(void))completeBlock;

/**
 *  从透明到不透明
 */
- (void)emerge;

/**
 *  从不透明到透明
 */
- (void)fake;

/**
 *  按钮震动动画
 */
- (void)startSelectedAnimation;

@end
