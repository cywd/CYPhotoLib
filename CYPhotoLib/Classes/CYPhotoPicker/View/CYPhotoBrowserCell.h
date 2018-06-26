//
//  CYPhotoBrowserCell.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface CYPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (weak, nonatomic) IBOutlet UIButton *singleSelBtn;
@property (weak, nonatomic) IBOutlet UIButton *selBtn;

@property (copy, nonatomic) void(^sigleSelectedBlock)(BOOL isSelected);
@property (nonatomic, copy) void(^selectedBlock)(BOOL isSelected);
@property (nonatomic, copy) void(^imgTapBlock)(void);

@property (nonatomic, copy) void(^lowInfoTapBlock)(void);
@property (nonatomic, copy) void(^unableTapBlock)(void);

@end
