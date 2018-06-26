//
//  CYPhotoAlbumListController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAlbumListController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoAlbumCell.h"
#import "CYPhotoBrowserController.h"
#import "CYAlbum.h"
#import "CYPhotoCenter.h"

@interface CYPhotoAlbumListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CYPhotoAlbumListController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[CYPhotoAlbumCell class] forCellReuseIdentifier:NSStringFromClass([CYPhotoAlbumCell class])];
    
    [self setupCancelBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraints:@[leftConstraint, topConstraint, rightConstraint, bottomConstraint]];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CYPhotoAlbumCell class])];
    cell.album = self.assetCollections[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CYPhotoBrowserController *browser = [[CYPhotoBrowserController alloc] init];
    browser.isSingleSel = self.isSingleSel;
    CYAlbum *info = self.assetCollections[indexPath.row];
    
    browser.album = info;
    browser.assets = info.assets;
    browser.collectionTitle = info.name;
//    browser.collectionTitle = NSLocalizedString(info.albumName, @"");
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
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
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
