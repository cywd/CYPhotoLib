//
//  CYPhotoHeader.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#ifndef CYPhotoHeader_h
#define CYPhotoHeader_h

#define SCREEN_W    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_H    ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_B    [[UIScreen mainScreen] bounds]

#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define AblumsListLineColor RGBColor(192, 192, 192)
#define BGCOLOR  RGBColor(237, 238, 242)
#define BTNCOLOR RGBColor(38, 184, 243)
#define CLEARCOLOR [UIColor clearColor]
#define WHITECOLOR [UIColor whiteColor]
#define BLACKCOLOR [UIColor blackColor]

#define Space 5

#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

#define PhotoLibraryChangeNotification @"PhotoLibraryChangeNotification"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "CYPhotoCenter.h"
#import "CYPhotoAblumListController.h"
#import "CYPhotoManager.h"
#import "CYPhotoBrowserController.h"

#import "UIView+CY_1pxLine.h"
#import "UIView+CYRect.h"
#import "UIView+CYAnimation.h"
#import "UIButton+CYCreate.h"
#import "UIImage+CYCutDown.h"
#import "NSString+CYPHChineseName.h"




#endif /* CYPhotoHeader_h */
