//
//  CYPhotoAssetCell.m
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAssetCell.h"
#import <Photos/Photos.h>
#import "CYPhotoManager.h"
#import "CYPhotoCenter.h"
#import "CYPhotoHeader.h"

@interface CYPhotoAssetCell ()

@property (nonatomic, assign) int32_t imageRequestID;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;
@property (weak, nonatomic) IBOutlet UIImageView *tanhao;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;


@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end

@implementation CYPhotoAssetCell

#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lowTap)];
    self.tanhao.userInteractionEnabled = YES;
    [self.tanhao addGestureRecognizer:tap];
}

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

- (void)lowTap {
    if (self.lowInfoTapBlock) self.lowInfoTapBlock();
}

- (IBAction)unableTap {
    if (self.unableTapBlock) self.unableTapBlock();
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
    
//    [self showLoadingIndicator];
    
    self.selBtn.hidden = YES;
    self.tanhao.hidden = YES;
    self.coverBtn.hidden = YES;

    dispatch_async(dispatch_queue_create("CYPhotoLibSetHiddenQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{

        // 耗时
        if (asset.mediaType == PHAssetMediaTypeImage) {

            [[CYPhotoManager manager] fetchImageDataBytesWithAsset:asset completion:^(CGFloat length) {
                // 这里要判断id一致再继续
                if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {

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

//                        [self hideLoadingIndicator];
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.coverBtn.hidden = NO;

//                [self hideLoadingIndicator];
            });
        }
    });
    
//    [self showLoadingIndicator];
    
    self.representedAssetIdentifier = asset.localIdentifier;
    
    int32_t imageRequestID = [[CYPhotoManager manager] fetchImageWithAsset:asset photoWidth:self.bounds.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
         [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    
    self.imageRequestID = imageRequestID;
    
    [self setNeedsLayout];
}

#pragma mark - receive and dealloc
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
