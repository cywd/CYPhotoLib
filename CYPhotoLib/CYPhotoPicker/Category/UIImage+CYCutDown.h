//
//  UIImage+CYCutDown.h
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CYCutDown)

//对图片尺寸进行压缩
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
