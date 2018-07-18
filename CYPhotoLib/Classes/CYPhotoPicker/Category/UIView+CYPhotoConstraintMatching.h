//
//  UIView+CYPhotoConstraintMatching.h
//  CYPhotoLib
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CYPhotoConstraintMatching)

- (NSLayoutConstraint *)constraintMatchingConstraint:(NSLayoutConstraint *)aConstraint;
- (NSArray *)constraintsMatchingConstraints:(NSArray *)constraints;
- (NSArray *)constraintsReferencingView:(UIView *)view;
- (void)removeMatchingConstraint:(NSLayoutConstraint *)aConstraint;
- (void)removeMatchingConstraints:(NSArray *)aArray;

@end
