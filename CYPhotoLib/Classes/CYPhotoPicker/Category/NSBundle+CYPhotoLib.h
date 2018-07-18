//
//  NSBundle+CYPhotoLib.h
//  CYPhotoLib
//
//  Created by cyrill on 2018/7/3.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (CYPhotoLib)

+ (NSBundle *)CYPhotoLibBundle;

+ (NSString *)cy_localizedStringForKey:(NSString *)key;
+ (NSString *)cy_localizedStringForKey:(NSString *)key value:(NSString *)value;

@end
