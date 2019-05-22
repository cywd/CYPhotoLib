//
//  CYPhotoAssetCell.h
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@protocol CYPhotoAssetCellDelegate;

@interface CYPhotoAssetCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, weak) id<CYPhotoAssetCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *singleSelBtn;
@property (weak, nonatomic) IBOutlet UIButton *selBtn;

@end

@protocol CYPhotoAssetCellDelegate <NSObject>

- (void)sigleSelected:(BOOL)isSelected cell:(CYPhotoAssetCell *)cell;
- (void)selected:(BOOL)isSelected cell:(CYPhotoAssetCell *)cell;
- (void)imgTapWithCell:(CYPhotoAssetCell *)cell;
- (void)lowInfoTapWithCell:(CYPhotoAssetCell *)cell;
- (void)unableTapWithCell:(CYPhotoAssetCell *)cell;


@end
