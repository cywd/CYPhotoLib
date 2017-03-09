//
//  UIView+CY_1pxLine.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CY_1pxLine)

/*
 * 寻找1像素的线(可以用来隐藏导航栏下面的黑线）
 */
- (UIImageView *)findHairlineImageViewUnder;

@end
