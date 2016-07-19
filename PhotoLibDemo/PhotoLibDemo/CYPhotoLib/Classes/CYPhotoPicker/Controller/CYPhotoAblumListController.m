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

@interface CYPhotoAblumListController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation CYPhotoAblumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationTitle:@"照片"];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)setupUI {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_W, SCREEN_H - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    
    [self setupCancelBtn];
}

- (void)setupCancelBtn {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)cancelBtnAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CYPhotoAblumCell * cell = [CYPhotoAblumCell cellForTableView:tableView info:self.assetCollections[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 62.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CYPhotoBrowserController *browser = [[CYPhotoBrowserController alloc] init];
    CYAblumInfo *info = self.self.assetCollections[indexPath.row];
    browser.assetCollection = info.assetCollection;
    browser.collectionTitle = [info.ablumName chineseName];;
    [self.navigationController pushViewController:browser animated:YES];
}

@end
