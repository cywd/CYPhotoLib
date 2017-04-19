//
//  CYPhotoBaseController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBaseController.h"
#import "CYPhotoHeader.h"

@interface CYPhotoBaseController ()

@end

@implementation CYPhotoBaseController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    // 将Navigationbar变成透明而不模糊
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar .shadowImage = [UIImage new];
//    self.navigationController.navigationBar .translucent = YES;
    
//    [self setupNavbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
//- (void)setupNavbar {
//    self.navigationController.navigationBar.barTintColor = BTNCOLOR;
//    self.navigationController.navigationBar.tintColor = WHITECOLOR;
//    //隐藏导航栏下面的线
//    [self.navigationController.navigationBar findHairlineImageViewUnder].hidden = YES;
//    
//    if (self.navigationController.viewControllers.count > 1) {
//        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[UIButton buttonWithFrame:CGRectMake(0, 0, 22, 22) Target:self Selector:@selector(backBtnAction) Image:@"CYBack.png" ImagePressed:@"CYBack.png"]];
//        self.navigationItem.leftBarButtonItem = item;
//    }
//}
//
//- (void)setNavigationTitle:(NSString *)title {
//    self.title = title;
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:WHITECOLOR}];
//}

#pragma mark - event response
- (void)backBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

// 横屏
- (BOOL)shouldAutorotate
{
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
