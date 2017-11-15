//
//  UIView+CYConstraintMatching.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "UIView+CYConstraintMatching.h"
#import "UIView+CYHierarchySupport.h"
#import "NSLayoutConstraint+CYConstraintMatching.h"

@implementation UIView (CYConstraintMatching)

- (NSLayoutConstraint *)constraintMatchingConstraint:(NSLayoutConstraint *)aConstraint {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint isEqualToLayoutConstraint:aConstraint]) {
            return constraint;
        }
    }
    
    for (UIView *view in self.superviews) {
        for (NSLayoutConstraint *constraint in view.constraints) {
            if ([constraint isEqualToLayoutConstraint:aConstraint]) {
                return constraint;
            }
        }
    }
    
    return nil;
}

- (NSArray *)constraintsMatchingConstraints:(NSArray *)constraints {
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints) {
        NSLayoutConstraint *match = [self constraintMatchingConstraint:constraint];
        if (match) {
            [array addObject:match];
        }
    }
    return array;
}

- (NSArray *)constraintsReferencingView:(UIView *)view {
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint.firstItem isEqual:view] || [constraint.secondItem isEqual:view]) {
            [array addObject:constraint];
        }
    }
    return array;
}

- (void)removeMatchingConstraint:(NSLayoutConstraint *)aConstraint {
    NSLayoutConstraint *match = [self constraintMatchingConstraint:aConstraint];
    if (match) {
        [self removeConstraint:match];
        [self.superview removeConstraint:match];
    }
}

- (void)removeMatchingConstraints:(NSArray *)aArray {
    for (NSLayoutConstraint *constraint in aArray) {
        [self removeMatchingConstraint:constraint];
    }
}

@end
