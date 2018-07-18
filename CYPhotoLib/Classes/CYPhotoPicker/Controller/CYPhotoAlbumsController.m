//
//  CYPhotoAlbumListController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAlbumsController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoAlbumCell.h"
#import "CYPhotoAssetsController.h"
#import "CYPhotoAlbum.h"
#import "CYPhotoCenter.h"
#import "CYPhotoManager.h"
#import "CYPhotoHud.h"
#import "CYPhotoConfig.h"
#import "NSBundle+CYPhotoLib.h"

@interface CYPhotoAlbumsController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CYPhotoAlbum *> *albums;  // 相册列表

@end

@implementation CYPhotoAlbumsController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSBundle cy_localizedStringForKey:@"Photos"];
    
    _albums = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[CYPhotoAlbumCell class] forCellReuseIdentifier:NSStringFromClass([CYPhotoAlbumCell class])];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle cy_localizedStringForKey:@"Cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchAlbums];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CYPhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CYPhotoAlbumCell class])];
    cell.album = self.albums[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CYPhotoAssetsController *browser = [[CYPhotoAssetsController alloc] init];
    CYPhotoAlbum *album = self.albums[indexPath.row];
    browser.album = album;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - event response
- (void)cancelBtnAction {
    [[CYPhotoCenter shareCenter] clearInfos];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods
- (void)fetchAlbums {
    
    CYPhotoHud *hud = [CYPhotoHud hud];
    if (!_albums.count) {
        [hud showProgressHUD];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[CYPhotoManager manager] fetchAllAlbumsAllowPickingVideo:NO allowPickingImage:YES needFetchAssets:NO sortByModificationDate:CYPhotoCenter.config.sortByModificationDate ascending:CYPhotoCenter.config.ascending completion:^(NSArray<CYPhotoAlbum *> *albumsArray) {
            self.albums = [NSMutableArray arrayWithArray:albumsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [hud hideProgressHUD];
            });
        }];
    });
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}

@end
