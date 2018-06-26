//
//  CYPhotoHud.h
//  PhotoLibDemo
//
//  Created by cyrill on 2018/6/26.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYPhotoHud : NSObject

+ (instancetype)hud;

- (void)showProgressHUD;

- (void)hideProgressHUD;

@end
