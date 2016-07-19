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

@property (weak, nonatomic) IBOutlet UIImageView *ablumCover;
@property (weak, nonatomic) IBOutlet UILabel *ablumName;
@property (weak, nonatomic) IBOutlet UILabel *ablumCount;

+ (instancetype)cellForTableView:(UITableView *)tableView info:(CYAblumInfo *)info;

@end
