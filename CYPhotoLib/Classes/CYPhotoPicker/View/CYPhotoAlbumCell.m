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

@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) UILabel *albumName;
@property (strong, nonatomic) UILabel *albumCount;

@end

@implementation CYPhotoAlbumCell

- (void)setAlbum:(CYAlbum *)album {
    _album = album;
    
    self.albumName.text = album.name;
    self.albumCount.text = @(album.count).stringValue;
    
    [[CYPhotoManager manager] fetchCoverImageWithAlbum:album completion:^(UIImage *image) {
        self.albumCover.image = image;
    }];
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

- (UIImageView *)albumCover {
    if (!_albumCover) {
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.frame = CGRectMake(15, 5, 70, 70);
        groupImageView.clipsToBounds = YES;
        groupImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_albumCover = groupImageView];
    }
    return _albumCover;
}

- (UILabel *)albumName {
    if (!_albumName) {
        UILabel *groupNameLabel = [[UILabel alloc] init];
        groupNameLabel.frame = CGRectMake(95, 15, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_albumName = groupNameLabel];
    }
    return _albumName;
}

- (UILabel *)albumCount {
    if (!_albumCount) {
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.font = [UIFont systemFontOfSize:13];
        groupPicCountLabel.textColor = [UIColor lightGrayColor];
        groupPicCountLabel.frame = CGRectMake(95, 40, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_albumCount = groupPicCountLabel];
    }
    return _albumCount;
}

@end