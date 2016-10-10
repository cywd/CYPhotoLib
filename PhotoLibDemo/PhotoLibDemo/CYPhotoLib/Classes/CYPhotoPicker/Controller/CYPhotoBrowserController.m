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

@interface CYPhotoBrowserController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UIView *bottomView; //底部面板
@property (strong, nonatomic) UIButton *isOriginalBtn; //原图按钮
@property (strong, nonatomic) UIView *bottomViewCover; //底部面板遮罩层
@property (strong, nonatomic) UILabel *comBtn; //完成按钮
@property (strong, nonatomic) UIButton *completeBtn; //完成按钮

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation CYPhotoBrowserController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CYPhotoCenter shareCenter].selectedCount = 20;
    
//    [self.view addSubview:_bottomView];
    
    
    [self setNavigationTitle:self.collectionTitle ? self.collectionTitle : @"相机胶卷"];
    
    // 滑动的时候隐藏navigation bar
//    self.navigationController.hidesBarsOnSwipe = YES;
    
    // 消除导航条返回键带的title
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [self setupUI];
    [self loadAssetData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"browserCell" forIndexPath:indexPath];
    
    PHAsset *asset = self.dataSource[indexPath.item];
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    
    [[CYPhotoManager manager] getImageDataLength:asset completeBlock:^(CGFloat length) {
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            cell.singleSelBtn.hidden = !_isSigleSel;
            
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
                //            cell.selBtn.hidden = YES;
            } else {
                // NO
                //            cell.tanhao.hidden = YES;
                cell.coverBtn.hidden = YES;
                //            cell.selBtn.hidden = NO;
            }
            
            
            
            if (!cell.coverBtn.hidden) {
                cell.selBtn.hidden = YES;
            }
            
            if (!cell.singleSelBtn.hidden) {
                cell.selBtn.hidden = YES;
                cell.tanhao.hidden = YES;
            }
        } else {
            cell.selBtn.hidden = YES;
            cell.tanhao.hidden = YES;
            cell.coverBtn.hidden = NO;
        }
        
    }];
    
    // 这里修改了 isResize 为 NO， 设置为YES会闪来闪去的
    [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(cell.w * 2, cell.h * 2) isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
        cell.imageIV.image = image;
    }];
    
    cell.selBtn.selected = [[CYPhotoCenter shareCenter].selectedPhotos containsObject:self.dataSource[indexPath.item]];
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    [cell setSelectedBlock:^(BOOL isSelected) {
        
        if (isSelected) {
            if ([[CYPhotoCenter shareCenter] isReachMaxSelectedCount]) {
                weakCell.selBtn.selected = NO;
                return;
            }
            [weakCell.selBtn startSelectedAnimation];
            [[CYPhotoCenter shareCenter].selectedPhotos addObject:weakSelf.dataSource[indexPath.item]];
        } else {
            [[CYPhotoCenter shareCenter].selectedPhotos removeObject:weakSelf.dataSource[indexPath.item]];
        }
        [weakSelf refreshBottomView];
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
    
    [cell setSigleSelectedBlock:^(BOOL isSelected) {
        
    }];
    
    return cell;
}

#pragma mark - private methods
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
    [self.view insertSubview:self.collectionView belowSubview:self.bottomView];
//    [self.view addSubview:self.collectionView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)loadAssetData
{
    self.dataSource = [[CYPhotoManager manager] fetchAssetsInCollection:self.assetCollection asending:NO];
    [self.collectionView reloadData];
}

- (void)refreshBottomView {
    if ([CYPhotoCenter shareCenter].selectedPhotos.count > 0) {
        self.bottomViewCover.hidden = YES;
        self.isOriginalBtn.selected = [CYPhotoCenter shareCenter].isOriginal;
        self.comBtn.text = [NSString stringWithFormat:@"完成(%zi)", [CYPhotoCenter shareCenter].selectedPhotos.count];
    } else {
        self.bottomViewCover.hidden = NO;
        self.isOriginalBtn.selected = NO;
        self.comBtn.text = @"完成";
    }
}

#pragma mark - event response
- (void)cancelBtnAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)completeClick:(UIButton *)sneder {
    [[CYPhotoCenter shareCenter] endPick];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getters and setters
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H-50, SCREEN_W, 50)];
        _bottomView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIView *)bottomViewCover {
    if (!_bottomViewCover) {
        _bottomViewCover = [[UIView alloc] init];
        _bottomViewCover.frame = self.bottomView.frame;
        [self.view insertSubview:_bottomViewCover aboveSubview:self.bottomView];
    }
    return _bottomViewCover;
}

- (UIButton *)isOriginalBtn {
    if (!_isOriginalBtn) {
        _isOriginalBtn = [[UIButton alloc] init];
        
    }
    return _isOriginalBtn;
}

- (UILabel *)comBtn {
    if (!_comBtn) {
        _comBtn = [[UILabel alloc] init];
        UIView *sendView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_W-70-14, 5, 70, 30)];
        sendView.backgroundColor = [UIColor grayColor];
        _comBtn.frame = sendView.bounds;
        [sendView addSubview:_comBtn];

        [sendView addSubview:self.completeBtn];
        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = sendView.bounds;
//        [btn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
//        [sendView addSubview:btn];
        
        [self.bottomView addSubview:sendView];
    }
    return _comBtn;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = self.comBtn.frame;
        [btn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _completeBtn = btn;
    }
    return _completeBtn;
}

@end
