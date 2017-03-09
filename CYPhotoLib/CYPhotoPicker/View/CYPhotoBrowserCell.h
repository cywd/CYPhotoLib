//
//  CYPhotoBrowserCell.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYPhotoBrowserCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageIV;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;
@property (weak, nonatomic) IBOutlet UIImageView *tanhao;
@property (weak, nonatomic) IBOutlet UIButton *singleSelBtn;

@property (copy, nonatomic) void(^sigleSelectedBlock)(BOOL isSelected);
@property (nonatomic, copy) void(^selectedBlock)(BOOL isSelected);
@property (nonatomic, copy) void(^imgTapBlock)();

@end
