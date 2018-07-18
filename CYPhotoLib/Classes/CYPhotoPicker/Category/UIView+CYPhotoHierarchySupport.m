//
//  UIView+CYHierarchySupport.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "UIView+CYPhotoHierarchySupport.h"

@implementation UIView (CYPhotoHierarchySupport)

- (NSArray *)superviews {
    NSMutableArray *array = [NSMutableArray array];
    UIView *view = self.superview;
    while (view) {
        [array addObject:view];
        view = view.superview;
    }
    return array;
}

- (BOOL)isAncestorOfView:(UIView *)aView {
    return [[aView superviews] containsObject:self];
}

- (UIView *)nearestCommonAncestorToView:(UIView *)aView {
    if ([self isEqual:aView]) {
        return self;
    }
    if ([self isAncestorOfView:aView]) {
        return self;
    }
    if ([aView isAncestorOfView:self]) {
        return aView;
    }
    
    NSArray *ancesrors = self.superviews;
    for (UIView *view in aView.superviews) {
        if ([ancesrors containsObject:view]) {
            return view;
        }
    }
    return nil;
}

@end
