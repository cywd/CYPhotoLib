//
//  UIView+CYPhotoHierarchySupport.h
//  CYPhotoLib
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CYPhotoHierarchySupport)

- (NSArray *)superviews;
- (BOOL)isAncestorOfView:(UIView *)aView;
- (UIView *)nearestCommonAncestorToView:(UIView *)aView;

@end
