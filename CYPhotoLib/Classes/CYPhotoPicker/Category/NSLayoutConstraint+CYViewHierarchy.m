//
//  NSLayoutConstraint+CYViewHierarchy.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "NSLayoutConstraint+CYViewHierarchy.h"

@implementation NSLayoutConstraint (CYViewHierarchy)

- (UIView *)firstView {
    return self.firstItem;
}

- (UIView *)secondView {
    return self.secondItem;
}

@end
