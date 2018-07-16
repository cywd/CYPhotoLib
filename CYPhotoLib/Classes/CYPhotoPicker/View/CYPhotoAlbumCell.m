//
//  CYPhotoAlbumCell.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAlbumCell.h"
#import "CYAlbum.h"
#import "CYPhotoManager.h"
#import "CYPhotoHeader.h"

@interface CYPhotoAlbumCell ()

@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation CYPhotoAlbumCell

- (void)setAlbum:(CYAlbum *)album {
    _album = album;
    
    self.nameLabel.text = album.name;
    self.countLabel.text = @(album.count).stringValue;
    
    [[CYPhotoManager manager] fetchCoverImageWithAlbum:album completion:^(UIImage *image) {
        self.coverImageView.image = image;
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImageView.frame = CGRectMake(15, 5, self.bounds.size.height-10, self.bounds.size.height-10);
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame)+10, 15, self.frame.size.width - 100, 20);
    self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame)+10, 40, self.frame.size.width - 100, 20);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:13];
        _countLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_countLabel];
    }
    return _countLabel;
}

@end
