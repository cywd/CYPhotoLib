//
//  CYPhotoHeader.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#ifndef CYPhotoHeader_h
#define CYPhotoHeader_h


#define CYPHOTOLIB_SCREEN_W    ([[UIScreen mainScreen] bounds].size.width)
#define CYPHOTOLIB_SCREEN_H    ([[UIScreen mainScreen] bounds].size.height)
#define CYPHOTOLIB_SCREEN_B    [[UIScreen mainScreen] bounds]

#define CYPHOTOLIB_TABBAR_H           49
#define CYPHOTOLIB_NAVBAR_H           64
#define CYPHOTOLIB_NAVBAR_H_NoSsatus  44

#define CYPHOTOLIB_RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define CYPHOTOLIB_AblumsListLineColor    CYPHOTOLIB_RGBColor(192, 192, 192)
#define CYPHOTOLIB_BGCOLOR                CYPHOTOLIB_RGBColor(237, 238, 242)
#define CYPHOTOLIB_CLEARCOLOR             [UIColor clearColor]

#define CYPHOTOLIB_NAV_BAR_COLOR          [UIColor purpleColor]
#define CYPHOTOLIB_COMPLETE_BTN_BG_COLOR  CYPHOTOLIB_NAV_BAR_COLOR

#define CYPHOTOLIB_SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define CYPHOTOLIB_SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

#define CYPHOTOLIB_PhotoLibraryChangeNotification  @"CYPHOTOLIB_PhotoLibraryChangeNotification"
#define CYPHOTOLIB_LOADING_DID_END_NOTIFICATION    @"CYPHOTOLIB_LOADING_DID_END_NOTIFICATION"
#define CYPHOTOLIB_PROGRESS_NOTIFICATION           @"CYPHOTOLIB_PROGRESS_NOTIFICATION"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


#endif /* CYPhotoHeader_h */
