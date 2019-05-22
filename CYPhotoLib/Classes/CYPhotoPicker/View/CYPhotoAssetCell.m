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
#import "CYPhotoConfig.h"

@interface CYPhotoAssetCell ()

@property (nonatomic, assign) int32_t imageRequestID;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;
@property (weak, nonatomic) IBOutlet UIImageView *tanhao;

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
    if ([self.delegate respondsToSelector:@selector(selected:cell:)]) {
        [self.delegate selected:sender.selected cell:self];
    }
    
}

- (IBAction)imageTapAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(imgTapWithCell:)]) {
        [self.delegate imgTapWithCell:self];
    }
}

- (IBAction)sigleSelectBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(sigleSelected:cell:)]) {
        [self.delegate sigleSelected:sender.selected cell:self];
    }
}

- (void)lowTap {
    if ([self.delegate respondsToSelector:@selector(lowInfoTapWithCell:)]) {
        [self.delegate lowInfoTapWithCell:self];
    }
}

- (IBAction)unableTap {
    if ([self.delegate respondsToSelector:@selector(unableTapWithCell:)]) {
        [self.delegate unableTapWithCell:self];
    }
}

#pragma mark - private methods

#pragma mark - getters and setters
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    
    self.selBtn.hidden = YES;
    self.tanhao.hidden = YES;
    self.coverBtn.hidden = YES;
    
//    dispatch_queue_t dispatchQueue = dispatch_queue_create("CYPhotoLibSetHiddenQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(dispatchQueue, ^{
        
        // 耗时
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [[CYPhotoManager manager] fetchImageDataBytesWithAsset:asset completion:^(CGFloat len) {
                
                CGFloat length = len * 0.001;
                
                // 这里要判断id一致再继续
                if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        if (length == 0) {
                            self.coverBtn.hidden = NO;
                        } else {
                            BOOL warning = NO;
                            BOOL disabled = NO;
                            if ([CYPhotoCenter shareCenter].config.minWarningDataLength > 0) {
                                
                                warning = warning || length < (1024 * [CYPhotoCenter shareCenter].config.minWarningDataLength / 1000.0);
                            }
                            
                            CGFloat warningAspectRatio = [CYPhotoCenter shareCenter].config.warningAspectRatio;
                            if (warningAspectRatio > 0) {
                                warning = warning || (width/height > warningAspectRatio || height/width > warningAspectRatio);
                            }
                            
                            
                            if ([CYPhotoCenter shareCenter].config.minDisabledDataLength > 0) {
                                BOOL disabled_tmp = (length < [CYPhotoCenter shareCenter].config.minDisabledDataLength * 1024 / 1000.0);
                                
                                disabled = disabled || disabled_tmp;
                            }
                            
                            if ([CYPhotoCenter shareCenter].config.maxDisabledDataLength > 0) {
                                BOOL disabled_tmp = (length > [CYPhotoCenter shareCenter].config.maxDisabledDataLength * 1024 / 1000.0);
                                
                                disabled = disabled || disabled_tmp;
                            }
                            
                            CGFloat disabledAspectRatio = [CYPhotoCenter shareCenter].config.disabledAspectRatio;
                            if (disabledAspectRatio > 0) {
                                disabled = disabled || (width/height > disabledAspectRatio || height/width > disabledAspectRatio);
                            }
                            
                            if (warning) {
                                self.tanhao.hidden = NO;
                            } else {
                                self.tanhao.hidden = YES;
                            }
                            
                            if (disabled) {
                                self.tanhao.hidden = YES;
                                self.coverBtn.hidden = NO;
                            } else {
                                self.coverBtn.hidden = YES;
                            }
                            
                            
                            
                            self.selBtn.hidden = !self.coverBtn.hidden;
                            
                            if (!self.singleSelBtn.hidden) {
                                self.selBtn.hidden = YES;
                                self.tanhao.hidden = YES;
                            }
                         
                        }
                    });
                }
            }];
                
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.coverBtn.hidden = NO;
            });
        }
    });
    
    
    self.representedAssetIdentifier = asset.localIdentifier;

    int32_t imageRequestID = [[CYPhotoManager manager] fetchImageWithAsset:asset photoWidth:self.bounds.size.width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {

        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.imageView.image = image;
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
