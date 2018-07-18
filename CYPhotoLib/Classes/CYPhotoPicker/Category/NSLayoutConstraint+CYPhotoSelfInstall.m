//
//  NSLayoutConstraint+CYSelfInstall.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "NSLayoutConstraint+CYPhotoSelfInstall.h"
#import "UIView+CYPhotoHierarchySupport.h"
#import "NSLayoutConstraint+CYPhotoViewHierarchy.h"

@implementation NSLayoutConstraint (CYPhotoSelfInstall)

- (BOOL)install {
    // Handle Unary contraint
    if (self.isUnary) {
        [self.firstItem addConstraint:self];
        return YES;
    }
    
    // Find nearest common ancestor
    UIView *view = [self.firstView nearestCommonAncestorToView:self.secondView];
    if (!view) {
        return NO;
    }
    
    [view addConstraint:self];
    return YES;
}

- (BOOL)install:(float)priority {
    self.priority = priority;
    return [self install];
}

- (void)remove {
    if (self.isUnary) {
        UIView *view = self.firstView;
        [view removeConstraint:self];
        return;
    }
    
    UIView *view = [self.firstView nearestCommonAncestorToView:self.secondView];
    if (!view) return;
    
    [view removeConstraint:self];
}

- (BOOL)isUnary {
    if (self.secondView) {
        return false;
    }
    return true;
}

@end
