//
//  CYPhotoBrowserCell.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBrowserCell.h"
#import <Photos/Photos.h>
#import "CYPhotoManager.h"
#import "CYPhotoCenter.h"
#import "UIView+CYRect.h"

@interface CYPhotoBrowserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageIV;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;
@property (weak, nonatomic) IBOutlet UIImageView *tanhao;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;


@end

@implementation CYPhotoBrowserCell

#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageIV.image = nil;
}

#pragma mark - public methods


#pragma mark - event response
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

#pragma mark - private methods
- (void)showLoadingIndicator {
    self.blurView.hidden = NO;
}

- (void)hideLoadingIndicator {
    self.blurView.hidden = YES;
}

#pragma mark - getters and setters
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    
    
    
    self.selBtn.hidden = YES;
    self.tanhao.hidden = YES;
    self.coverBtn.hidden = YES;
    
    
    dispatch_async(dispatch_queue_create("CYPhotoLibSetHiddenQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        // 耗时
        BOOL isLocal = [[CYPhotoManager manager] isInLocalAblumWithAsset:asset];
        if (isLocal && (asset.mediaType == PHAssetMediaTypeImage)) {
            
            [[CYPhotoManager manager] getImageDataLength:asset completeBlock:^(CGFloat length) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (length < (102400 / 1000.0) ) {
                        // YES
                        self.tanhao.hidden = NO;
                    } else if (width/height > 2 || height/width > 2) {
                        // YES
                        self.tanhao.hidden = NO;
                    } else {
                        // NO
                        self.tanhao.hidden = YES;
                    }
                    
                    if (length < 71680 / 1000.0 || length > 6291456 / 1000.0) {
                        // YES
                        self.tanhao.hidden = YES;
                        self.coverBtn.hidden = NO;
                        //            cell.selBtn.hidden = YES;
                    } else {
                        // NO
                        //            cell.tanhao.hidden = YES;
                        self.coverBtn.hidden = YES;
                        //            cell.selBtn.hidden = NO;
                    }
                    
                    self.selBtn.hidden = !self.coverBtn.hidden;
                    
                    if (!self.singleSelBtn.hidden) {
                        self.selBtn.hidden = YES;
                        self.tanhao.hidden = YES;
                    }
                    
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.coverBtn.hidden = NO;
            });
        }
    });
    
    
    [self showLoadingIndicator];
    
    dispatch_async(dispatch_queue_create("CYPhotoLibSetImageQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        // 这里修改了 isResize 为 NO， 设置为YES会闪来闪去的
        [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(self.w * 2, self.h * 2) isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageIV.image = image;
                
                [self hideLoadingIndicator];
            });
        }];
    });
    
    
}

#pragma mark - receive and dealloc
- (void)dealloc {
    
}

@end
