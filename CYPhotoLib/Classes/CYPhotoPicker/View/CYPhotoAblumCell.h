//
//  CYPhotoAblumCell.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYAblumInfo;

@interface CYPhotoAblumCell : UITableViewCell

@property (strong, nonatomic) UIImageView *ablumCover;
@property (strong, nonatomic) UILabel *ablumName;
@property (strong, nonatomic) UILabel *ablumCount;

+ (instancetype)cellForTableView:(UITableView *)tableView info:(CYAblumInfo *)info;

@end
