//
//  CYPhotoBrowserController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoBrowserController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoBrowserCell.h"
#import "CYPhotoManager.h"
#import "CYPhotoPreviewerController.h"

@interface CYPhotoBrowserController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation CYPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationTitle:self.collectionTitle ? self.collectionTitle : @"相机胶卷"];
    
    // 滑动的时候隐藏navigation bar
//    self.navigationController.hidesBarsOnSwipe = YES;
    
    // 消除导航条返回键带的title
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    [self setupUI];
    [self loadAssetData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - collectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"browserCell" forIndexPath:indexPath];
    
    PHAsset *asset = self.dataSource[indexPath.item];
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    
    [[CYPhotoManager manager] getImageDataLength:asset completeBlock:^(CGFloat length) {
        
        if (length < (102400 / 1000.0) ) {
            // YES
            cell.tanhao.hidden = NO;
        } else if (width/height > 2 || height/width > 2) {
            // YES
            cell.tanhao.hidden = NO;
        } else {
            // NO
            cell.tanhao.hidden = YES;
        }
        
        if (length < 71680 / 1000.0 || length > 6291456 / 1000.0) {
            // YES
            cell.tanhao.hidden = YES;
            cell.coverBtn.hidden = NO;
            cell.selBtn.hidden = YES;
        } else {
            // NO
//            cell.tanhao.hidden = YES;
            cell.coverBtn.hidden = YES;
            cell.selBtn.hidden = NO;
        }
    }];
    
    [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(cell.w * 2, cell.h * 2) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        cell.imageIV.image = image;
    }];
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    [cell setSelectedBlock:^(BOOL isSelected) {
        
        if (isSelected) {
            
        } else {
            
        }
    }];
    
    [cell setImgTapBlock:^{
        CYPhotoPreviewerController *previewer = [[CYPhotoPreviewerController alloc] init];
        if (weakCell.selBtn.selected) {
            previewer.isPreviewSelectedPhotos = YES;
        }
        previewer.selectedAsset = weakSelf.dataSource[indexPath.item];
        
        previewer.previewPhotos = weakSelf.dataSource.copy;
        
        [previewer setBackBlock:^{
            [collectionView reloadData];
        }];
        
        [weakSelf.navigationController pushViewController:previewer animated:YES];
    }];
    
    return cell;
}

#pragma mark - ui
- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((SCREEN_W - 5 * 3) / 4, (SCREEN_W - 5 * 3) / 4);
    layout.minimumInteritemSpacing = 5.0;
    layout.minimumLineSpacing = 5.0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_W, SCREEN_H-64) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CYPhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"browserCell"];
//    [self.view insertSubview:self.collectionView belowSubview:self]
    [self.view addSubview:self.collectionView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)loadAssetData
{
    self.dataSource = [[CYPhotoManager manager] fetchAssetsInCollection:self.assetCollection asending:NO];
    [self.collectionView reloadData];
}

#pragma mark - action
- (void)cancelBtnAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
