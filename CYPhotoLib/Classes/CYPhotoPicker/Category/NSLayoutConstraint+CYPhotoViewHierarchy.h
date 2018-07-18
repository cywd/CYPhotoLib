//
//  NSLayoutConstraint+CYPhotoViewHierarchy.h
//  CYPhotoLib
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (CYPhotoViewHierarchy)

@property (nonatomic, readonly) UIView *firstView;
@property (nonatomic, readonly) UIView *secondView;

@end
