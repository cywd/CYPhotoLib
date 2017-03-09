//
//  CYPhotoBottomCollectionViewCell.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/14.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBottomCollectionViewCell.h"

@implementation CYPhotoBottomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)deleteItem:(UIButton *)sender forEvent:(UIEvent *)event {
    if (self.deleteTapBlock) {
        self.deleteTapBlock(self.indexPath);
    }
}

@end
