//
//  CYPhotoAblumCell.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAblumCell.h"
#import "CYAblumInfo.h"
#import "CYPhotoManager.h"
#import "CYPhotoHeader.h"
#import "NSString+CYPHChineseName.h"

@implementation CYPhotoAblumCell

+ (instancetype)cellForTableView:(UITableView *)tableView info:(CYAblumInfo *)info {
    
    static NSString *cellID = @"CYPhotoAblumCell";
    
    // 复用
    CYPhotoAblumCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[CYPhotoAblumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [[CYPhotoManager manager] fetchImageInAsset:info.coverAsset size:CGSizeMake(120, 120) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        
        cell.ablumCover.image = image;
    }];
    cell.ablumName.text = [info.ablumName chineseName];
//    cell.ablumName.text = NSLocalizedString(info.ablumName, @"");
    cell.ablumCount.text = [NSString stringWithFormat:@"(%zi)",info.count];
    
//    //line
//    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(100, 61 - CYPHOTOLIB_SINGLE_LINE_ADJUST_OFFSET, CYPHOTOLIB_SCREEN_W - 100, CYPHOTOLIB_SINGLE_LINE_WIDTH)];
//    line.backgroundColor = CYPHOTOLIB_AblumsListLineColor;
//    [cell.contentView addSubview:line];
    
    // indicator
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (UIImageView *)ablumCover {
    if (!_ablumCover) {
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.frame = CGRectMake(15, 5, 70, 70);
        groupImageView.clipsToBounds = YES;
        groupImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_ablumCover = groupImageView];
    }
    return _ablumCover;
}

- (UILabel *)ablumName {
    if (!_ablumName) {
        UILabel *groupNameLabel = [[UILabel alloc] init];
        groupNameLabel.frame = CGRectMake(95, 15, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_ablumName = groupNameLabel];
    }
    return _ablumName;
}

- (UILabel *)ablumCount {
    if (!_ablumCount) {
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.font = [UIFont systemFontOfSize:13];
        groupPicCountLabel.textColor = [UIColor lightGrayColor];
        groupPicCountLabel.frame = CGRectMake(95, 40, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_ablumCount = groupPicCountLabel];
    }
    return _ablumCount;
}

@end
