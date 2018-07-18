//
//  NSLayoutConstraint+CYPhotoViewHierarchy.m
//  CYPhotoLib
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "NSLayoutConstraint+CYPhotoViewHierarchy.h"

@implementation NSLayoutConstraint (CYPhotoViewHierarchy)

- (UIView *)firstView {
    return self.firstItem;
}

- (UIView *)secondView {
    return self.secondItem;
}

@end
