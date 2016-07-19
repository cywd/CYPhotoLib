//
//  UIView+CY_1pxLine.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "UIView+CY_1pxLine.h"
#import <UIKit/UIKit.h>

@implementation UIView (CY_1pxLine)

- (UIImageView *)findHairlineImageViewUnder
{
    if ([self isKindOfClass:UIImageView.class]) {
        return (UIImageView *)self;
    }
    
    for (UIView * subview in self.subviews) {
        UIImageView *imageView = [subview findHairlineImageViewUnder];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
