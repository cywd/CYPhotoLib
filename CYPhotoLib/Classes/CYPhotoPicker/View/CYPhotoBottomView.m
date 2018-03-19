//
//  CYPhotoBottomView.m
//  PhotoLibDemo
//
//  Created by Cyrill on 2017/11/7.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYPhotoBottomView.h"

@interface CYPhotoBottomView()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *completeBtn;

@end

@implementation CYPhotoBottomView

- (instancetype)init {
    if (self = [super init]) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.collectionView];
    
    NSLayoutConstraint *leftConstraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraints:@[leftConstraint1, rightConstraint1, bottomConstraint1]];
    
    NSLayoutConstraint *heightConstraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90.0];
    [self.collectionView addConstraint:heightConstraint1];
    
    self.completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.completeBtn];
    
    NSLayoutConstraint *rightConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15.0];
    NSLayoutConstraint *topConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0];
    [self addConstraints:@[rightConstraint2, topConstraint2]];
    
    NSLayoutConstraint *widthConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:190*0.5];
    NSLayoutConstraint *heightConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];
    [self.completeBtn addConstraints:@[widthConstraint2, heightConstraint2]];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] init];
    }
    return _collectionView;
}

@end
