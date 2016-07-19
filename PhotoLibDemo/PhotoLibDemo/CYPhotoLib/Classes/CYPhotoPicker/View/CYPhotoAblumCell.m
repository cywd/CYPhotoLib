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

@implementation CYPhotoAblumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellForTableView:(UITableView *)tableView info:(CYAblumInfo *)info {
    //表格列表不多，不选择重用机制
    CYPhotoAblumCell * cell = [[NSBundle mainBundle]loadNibNamed:@"CYPhotoAblumCell" owner:tableView options:nil][0];
    [[CYPhotoManager manager] fetchImageInAsset:info.coverAsset size:CGSizeMake(120, 120) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        
        cell.ablumCover.image = image;
    }];
    cell.ablumName.text = [info.ablumName chineseName];
    cell.ablumCount.text = [NSString stringWithFormat:@"(%ld)",info.count];
    
    //line
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(100, 61 - SINGLE_LINE_ADJUST_OFFSET, SCREEN_W - 100, SINGLE_LINE_WIDTH)];
    line.backgroundColor = AblumsListLineColor;
    [cell.contentView addSubview:line];
    
    //indicator
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
