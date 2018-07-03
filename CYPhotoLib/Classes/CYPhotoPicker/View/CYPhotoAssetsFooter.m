//
//  CYPhotoAssetsFooter.m
//  MkmyIOS
//
//  Created by Cyrill on 2016/10/14.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAssetsFooter.h"

@interface CYPhotoAssetsFooter()

@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation CYPhotoAssetsFooter

- (void)setCount:(NSInteger)count {
    _count = count;
    
    if (count > 0) {
        self.footerLabel.text = [NSString stringWithFormat:@"有 %ld 张图片", (long)count];
    }
}

@end
