//
//  NSLayoutConstraint+CYConstraintMatching.h
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (CYConstraintMatching)

- (BOOL)isEqualToLayoutConstraint:(NSLayoutConstraint *)constraint;

@end
