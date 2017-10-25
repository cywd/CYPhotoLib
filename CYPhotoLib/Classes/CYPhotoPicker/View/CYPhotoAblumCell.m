//
//  CYPhotoAblumCell.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAblumCell.h"
#import "CYAblumModel.h"
#import "CYPhotoManager.h"
#import "CYPhotoHeader.h"
#import "NSString+CYPHChineseName.h"

@interface CYPhotoAblumCell ()

@property (strong, nonatomic) UIImageView *ablumCover;
@property (strong, nonatomic) UILabel *ablumName;
@property (strong, nonatomic) UILabel *ablumCount;

@end

@implementation CYPhotoAblumCell
- (void)setInfo:(CYAblumModel *)info {
    _info = info;
    
    [[CYPhotoManager manager] fetchImageInAsset:info.coverAsset size:CGSizeMake(120, 120) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        
        self.ablumCover.image = image;
    }];
    self.ablumName.text = [info.ablumName chineseName];
    //    cell.ablumName.text = NSLocalizedString(info.ablumName, @"");
    self.ablumCount.text = [NSString stringWithFormat:@"(%zi)",info.count];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
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
