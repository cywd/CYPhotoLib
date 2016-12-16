//
//  ViewController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/6/20.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "ViewController.h"
#import "CYPhotoLib.h"

//#import <Photos/Photos.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(UIButton *)sender {
    
}

- (IBAction)btnClick:(UIButton *)sender {
    
    [self gotoPhotos];
}

- (void)gotoPhotos
{
    CYPhotoPicker *picker = [[CYPhotoPicker alloc] init];
    [picker showInSender:self isSingleSel:NO handle:^(NSArray *photos) {
        
        NSMutableArray *assetArray = [CYPhotoCenter shareCenter].selectedPhotos;
        
        [[CYPhotoManager manager] fetchImageInAsset:assetArray[0] size:PHImageManagerMaximumSize isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
           
            
        }];
        
    }];
}

@end
