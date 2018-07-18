//
//  NSLayoutConstraint+CYPhotoSelfInstall.h
//  CYPhotoLib
//
//  Created by Cyrill on 2017/11/15.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (CYPhotoSelfInstall)

- (BOOL)install;
- (BOOL)install:(float)priority;
- (void)remove;

@end
