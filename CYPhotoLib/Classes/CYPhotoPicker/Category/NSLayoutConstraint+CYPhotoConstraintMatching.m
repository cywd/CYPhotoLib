//
//  NSLayoutConstraint+CYConstraintMatching.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "NSLayoutConstraint+CYPhotoConstraintMatching.h"

@implementation NSLayoutConstraint (CYPhotoConstraintMatching)

- (BOOL)isEqualToLayoutConstraint:(NSLayoutConstraint *)constraint {
    if (self.firstItem != constraint.firstItem) return NO;
    if (self.secondItem != constraint.secondItem) return NO;
    if (self.firstAttribute != constraint.firstAttribute) return NO;
    if (self.secondAttribute != constraint.secondAttribute) return NO;
    if (self.relation != constraint.relation) return NO;
    if (self.multiplier != constraint.multiplier) return NO;
    if (self.constant != constraint.constant) return NO;
    
    return YES;
}

@end
