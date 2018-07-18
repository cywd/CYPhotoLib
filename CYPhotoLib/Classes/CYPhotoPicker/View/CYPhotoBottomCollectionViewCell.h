//
//  CYPhotoBottomCollectionViewCell.h
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/14.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYPhotoAsset;

@interface CYPhotoBottomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, strong) CYPhotoAsset *asset;


@property (nonatomic, copy) void(^deleteTapBlock)(NSIndexPath *indexPath, CYPhotoAsset *ast);

@end
