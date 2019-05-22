//
//  CYPhotoBottomCollectionViewCell.h
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/14.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYPhotoAsset;

@protocol CYPhotoBottomCollectionViewCellDelegate;

@interface CYPhotoBottomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, strong) CYPhotoAsset *asset;

@property (nonatomic, weak) id<CYPhotoBottomCollectionViewCellDelegate> delegate;

@end

@protocol CYPhotoBottomCollectionViewCellDelegate <NSObject>

- (void)bottom_imgTapWithCell:(CYPhotoBottomCollectionViewCell *)cell;

- (void)bottom_deleteTap:(CYPhotoAsset *)asset cell:(CYPhotoBottomCollectionViewCell *)cell;

@end
