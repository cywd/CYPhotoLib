//
//  CYPhotoBrowserCell.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBrowserCell.h"

@implementation CYPhotoBrowserCell



- (IBAction)selectBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.selectedBlock) self.selectedBlock(sender.selected);
}

- (IBAction)imageTapAction:(UIButton *)sender {
    if (self.imgTapBlock) self.imgTapBlock();
}

- (IBAction)sigleSelectBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.sigleSelectedBlock) self.sigleSelectedBlock(sender.selected);
}

@end
