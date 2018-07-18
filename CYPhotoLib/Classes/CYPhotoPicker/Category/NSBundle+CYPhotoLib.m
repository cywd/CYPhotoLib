//
//  NSBundle+CYPhotoLib.m
//  CYPhotoLib
//
//  Created by cyrill on 2018/7/3.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

#import "NSBundle+CYPhotoLib.h"
#import "CYPhotoPicker.h"

@implementation NSBundle (CYPhotoLib)

+ (NSBundle *)CYPhotoLibBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[CYPhotoPicker class]];
    NSURL *url = [bundle URLForResource:@"CYPhotoLib" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)cy_localizedStringForKey:(NSString *)key {
    return [self cy_localizedStringForKey:key value:nil];
}

+ (NSString *)cy_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [self CYPhotoLibBundle];
    NSString *string = [bundle localizedStringForKey:key value:value table:nil];
    return string;
}

@end
