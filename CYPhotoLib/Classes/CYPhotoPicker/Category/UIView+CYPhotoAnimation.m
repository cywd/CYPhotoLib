//
//  UIView+CYPhotoAnimation.m
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "UIView+CYPhotoAnimation.h"

#define CYPhotoLibBottomRect CGRectMake(self.frame.origin.x, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, self.frame.size.height)


@implementation UIView (CYPhotoAnimation)

#pragma mark - 底部出现动画
- (void)showFromBottom {
    CGRect rect = self.frame;
    self.frame = CYPhotoLibBottomRect;
    [self executeAnimationWithFrame:rect completion:nil];
}

#pragma mark - 底部消失动画
- (void)dismissToBottomWithcompletion:(void(^)(void))completion {
    [self executeAnimationWithFrame:CYPhotoLibBottomRect completion:completion];
}

#pragma mark - 背景浮现动画
- (void)emerge {
    self.alpha = 0.0;
    [self executeAnimationWithAlpha:0.2 completion:nil];
}

#pragma mark - 背景淡去动画
- (void)fake {
    [self executeAnimationWithAlpha:0.f completion:nil];
}

#pragma mark - 执行动画
- (void)executeAnimationWithAlpha:(CGFloat)alpha completion:(void(^)(void))completion{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = alpha;
    } completion:^(BOOL finished) {
        if (finished && completion) completion();
    }];
}

- (void)executeAnimationWithFrame:(CGRect)rect completion:(void(^)(void))completion{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = rect;
    } completion:^(BOOL finished) {
        if (finished && completion) completion();
    }];
}

#pragma mark - 按钮震动动画
- (void)startSelectedAnimation
{
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    ani.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)],
                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)],
                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    ani.removedOnCompletion = YES;
    ani.fillMode = kCAFillModeForwards;
    ani.duration = 0.4;
    [self.layer addAnimation:ani forKey:@"transformAni"];
}


@end
