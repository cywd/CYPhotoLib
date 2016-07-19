//
//  NSString+CYPHChineseName.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "NSString+CYPHChineseName.h"

@implementation NSString (CYPHChineseName)

- (NSString *)chineseName {
    NSArray * engNameList = @[@"All Photos", @"Recently Added", @"Camera Roll", @"My Photo Stream", @"Selfies", @"Videos", @"Favorites", @"Screenshots", @"Recently Deleted", @"Bursts"];
    NSArray * chineseNameList = @[@"所有照片", @"最近添加", @"相机胶卷", @"我的照片流", @"自拍", @"视频", @"最爱", @"屏幕快照", @"最近删除", @"连拍快照"];
    if ([engNameList containsObject:self]) {
        NSInteger index = [engNameList indexOfObject:self];
        return chineseNameList[index];
    }
    return self;
}

@end
