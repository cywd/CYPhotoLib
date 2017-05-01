//
//  CYPhotoAblumListController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAblumListController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoAblumCell.h"
#import "CYPhotoBrowserController.h"
#import "CYAblumInfo.h"
#import "NSString+CYPHChineseName.h"
#import "CYPhotoCenter.h"

@interface CYPhotoAblumListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation CYPhotoAblumListController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    [self.view addSubview:self.tableView];
    [self setupCancelBtn];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CYPhotoAblumCell * cell = [CYPhotoAblumCell cellForTableView:tableView info:self.assetCollections[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CYPhotoBrowserController *browser = [[CYPhotoBrowserController alloc] init];
    
    browser.isSingleSel = self.isSingleSel;
    CYAblumInfo *info = self.assetCollections[indexPath.row];
    
    browser.info = info;
    browser.assetCollection = info.assetCollection;
    browser.collectionTitle = [info.ablumName chineseName];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - event response
- (void)cancelBtnAction {
    [[CYPhotoCenter shareCenter] clearInfos];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods
- (void)setupCancelBtn {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CYPHOTOLIB_NAVBAR_H, CYPHOTOLIB_SCREEN_W, CYPHOTOLIB_SCREEN_H - CYPHOTOLIB_NAVBAR_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

#pragma mark - receive and dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    self.tableView = nil;
//    self.assetCollections = nil;
    
}

@end
