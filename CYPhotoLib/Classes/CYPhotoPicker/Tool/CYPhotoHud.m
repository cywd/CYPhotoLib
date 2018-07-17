//
//  CYPhotoHud.m
//  PhotoLibDemo
//
//  Created by cyrill on 2018/6/26.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

#import "CYPhotoHud.h"
#import "NSBundle+CYPhotoLib.h"

@implementation CYPhotoHud {
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
}

+ (instancetype)hud {
//    static id hud = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        hud = [[self alloc] init];
//    });
//    return hud;
    
    return [[self alloc] init];
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = [NSBundle cy_localizedStringForKey:@"Processing..."];
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        _HUDContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 120) / 2, ([UIScreen mainScreen].bounds.size.height - 90) / 2, 120, 90);
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        _HUDLabel.frame = CGRectMake(0,40, 120, 50);
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

@end
