//
//  CYPhotoAssetsController.m
//  CYPhotoLib
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoAssetsController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoAssetCell.h"
#import "CYPhotoAssetsFooter.h"
#import "CYPhotoManager.h"
#import "CYPhotoBottomCollectionViewCell.h"
#import "UIView+CYAnimation.h"
#import "CYPhotoCenter.h"
#import "UIView+CYPhotoConstraintMatching.h"

#import "CYPhotoAlbum.h"
#import "CYPhotoAsset.h"
#import "CYPhotoHud.h"
#import "CYPhotoConfig.h"

#import "NSBundle+CYPhotoLib.h"


static CGFloat TOOLBAR_HEIGHT = 135;


@interface CYPhotoAssetsController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    CGFloat _offsetItemCount;
}

@property (nonatomic, assign) BOOL shouldScrollToBottom; // 是否滚到底

@property (strong, nonatomic) UIButton *completeBtn; //完成按钮

// 已选
@property (nonatomic, strong) UILabel *haveSelectedLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *allCountLabel;

// UIToolbar 目测以后只能用 items了。上面盖了一层东西
//@property (nonatomic , weak  ) UIToolbar *toolBar;
@property (nonatomic , strong) UIView *toolBar;
// 底部CollectionView
@property (nonatomic , weak) UICollectionView *toolBarThumbCollectionView;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, strong) NSMutableArray<CYPhotoAsset *> *dataSource;
@property (nonatomic, strong) NSMutableArray<CYPhotoAsset *> *assets;

@end

@implementation CYPhotoAssetsController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.album.name ? self.album.name : [NSBundle cy_localizedStringForKey:@"Photos"];
    
    self.shouldScrollToBottom = YES;
    
    [self setupUI];
    
    self.collectionView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self fetchAssets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshBottomView:YES];
    
    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self someLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.toolBarThumbCollectionView) {
        return [CYPhotoCenter shareCenter].selectedPhotos.count;
    }
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.toolBarThumbCollectionView) {
    
        NSMutableArray *arr = [CYPhotoCenter shareCenter].selectedPhotos;
        CYPhotoAsset *asset = arr[indexPath.item];
        
        CYPhotoBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CYPhotoBottomCollectionViewCell class]) forIndexPath:indexPath];
        
        cell.indexPath = indexPath;
        cell.asset = asset;
        
        [[CYPhotoManager manager] fetchImageWithAsset:asset.asset photoWidth:cell.bounds.size.width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
            cell.imageView.image = image;
        }];
        
        __weak typeof(self)weakSelf = self;
        
        [cell setDeleteTapBlock:^(NSIndexPath *cellIndexPath, CYPhotoAsset *ast) {
            __strong typeof(self)strongSelf = weakSelf;
            [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:cellIndexPath.item];

            for (CYPhotoAsset *model in strongSelf.dataSource) {
                if ([model.asset.localIdentifier isEqualToString:ast.asset.localIdentifier]) {
                    NSInteger ind = [strongSelf.dataSource indexOfObject:model];
                    NSIndexPath *p = [NSIndexPath indexPathForItem:ind inSection:indexPath.section];
                    [strongSelf.collectionView reloadItemsAtIndexPaths:@[p]];
                }
            }
            [strongSelf refreshBottomView:NO];
        }];
        
        return cell;
    } else {
        CYPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CYPhotoAssetCell class]) forIndexPath:indexPath];
        
        cell.asset = self.dataSource[indexPath.item].asset;
        
        cell.singleSelBtn.hidden = !CYPhotoCenter.config.isSinglePick;
        
        BOOL isContent = NO;
        for (CYPhotoAsset *model in [CYPhotoCenter shareCenter].selectedPhotos) {
            if ([model.asset.localIdentifier isEqualToString:self.dataSource[indexPath.item].asset.localIdentifier]) {
                isContent = YES;
            }
        }

        cell.selBtn.selected = isContent;
        
        __weak typeof(cell) weakCell = cell;

        [cell setSelectedBlock:^(BOOL isSelected) {
            
            if (isSelected) {
                if ([[CYPhotoCenter shareCenter] isReachMaxSelectedCount]) {
                    weakCell.selBtn.selected = NO;
                    return;
                }
                [weakCell.selBtn startSelectedAnimation];
                [[CYPhotoCenter shareCenter].selectedPhotos addObject:self.dataSource[indexPath.item]];
                
                [self refreshBottomView:YES];
            } else {
                NSUInteger index = 0;
                for (CYPhotoAsset *model in [CYPhotoCenter shareCenter].selectedPhotos) {
                    if ([model.asset.localIdentifier isEqualToString:self.dataSource[indexPath.item].asset.localIdentifier]) {
                        index = [[CYPhotoCenter shareCenter].selectedPhotos indexOfObject:model];
                    }
                }
                
                [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:index];
                
                [self refreshBottomView:NO];
            }
        }];
    
        [cell setImgTapBlock:^{
            // CY-TODO: 这里处理一下
            // clicked image
        }];
        
        // 如果是单张图片选择
        [cell setSigleSelectedBlock:^(BOOL isSelected) {
            
            [[CYPhotoCenter shareCenter].selectedPhotos addObject:self.dataSource[indexPath.item]];
            
            [[CYPhotoCenter shareCenter] endPick];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [cell setUnableTapBlock:^{
            // CY-TODO: 提供给外界更改
            // 不可选提示信息
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"不可选择" message:@"图片不符合制作规定" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        
        [cell setLowInfoTapBlock:^{
            // CY-TODO: 提供给外界更改
            // 低分辨率提示信息
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"图片不太清晰" message:@"会影响制作效果" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    CYPhotoAssetsFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([CYPhotoAssetsFooter class]) forIndexPath:indexPath];
    footerView.count = self.album.count;
    CYPhotoAssetsFooter *reusableView = footerView;
    return reusableView;
}

#pragma mark - nofi
- (void)didChangeStatusBarOrientationNotification:(NSNotification *)notification {
    _offsetItemCount = self.collectionView.contentOffset.y / (_collectionLayout.itemSize.height + _collectionLayout.minimumLineSpacing);
}

#pragma mark - event response
- (void)cancelBtnAction {
    [[CYPhotoCenter shareCenter] clearInfos];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)completeClick:(UIButton *)sneder {
    if ([CYPhotoCenter shareCenter].isReachMinSelectedCount) {
        return;
    }
    
    [[CYPhotoCenter shareCenter] endPick];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods
- (void)fetchAssets {
    CYPhotoHud *hud = [CYPhotoHud hud];
    
    if (!_assets.count) {
        [hud showProgressHUD];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!self.album) {
            [[CYPhotoManager manager] fetchCameraRollAlbumAllowPickingVideo:CYPhotoCenter.config.allowPickingVideo allowPickingImage:CYPhotoCenter.config.allowPickingImage needFetchAssets:YES sortByModificationDate:CYPhotoCenter.config.sortByModificationDate ascending:CYPhotoCenter.config.ascending completion:^(CYPhotoAlbum *model) {
                self.album = model;
                self.assets = [NSMutableArray arrayWithArray:self.album.assets];
                self.dataSource = self.assets;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideProgressHUD];
                    self.collectionView.hidden = YES;
                    [self.collectionView reloadData];
                    [self scrollCollectionViewToBottom];
                });
            }];
        } else {
            [[CYPhotoManager manager] fetchAssetsFromFetchResult:self.album.result completion:^(NSArray<CYPhotoAsset *> *array) {
                self.assets = [NSMutableArray arrayWithArray:array];
                self.dataSource = self.assets;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideProgressHUD];
                    self.collectionView.hidden = YES;
                    [self.collectionView reloadData];
                    [self scrollCollectionViewToBottom];
                });
            }];
        }
    });
}

- (void)someLayout {
    UIEdgeInsets insets = CYPHOTOLIB_ViewSafeAreInsets(self.view);
    CGFloat bottomH = 0;
    CGFloat bottomCons = 0;
    
    if (CYPhotoCenter.config.isSinglePick) {
        bottomH = 5.0;
    } else {
        bottomH = TOOLBAR_HEIGHT;
        bottomCons = TOOLBAR_HEIGHT;
        
        NSArray *toolBarConstraints =  [self.view constraintsReferencingView:self.toolBar];
        [self.toolBar removeMatchingConstraints:toolBarConstraints];
        
        CGFloat left = insets.left>0?insets.left:0.f;
        CGFloat right = insets.right>0?insets.right:0.f;
        
        self.toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:left];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.toolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-right];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-insets.bottom];
        [self.view removeConstraints:@[leftConstraint, rightConstraint]];
        
        [self.view addConstraints:@[leftConstraint, rightConstraint, bottomConstraint]];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:TOOLBAR_HEIGHT];
        [self.toolBar addConstraint:heightConstraint];
        
        NSLayoutConstraint *leftConstraint1 = [NSLayoutConstraint constraintWithItem:self.toolBarThumbCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *rightConstraint1 = [NSLayoutConstraint constraintWithItem:self.toolBarThumbCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *bottomConstraint1 = [NSLayoutConstraint constraintWithItem:self.toolBarThumbCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.toolBar addConstraints:@[leftConstraint1, rightConstraint1, bottomConstraint1]];
        
        NSLayoutConstraint *heightConstraint1 = [NSLayoutConstraint constraintWithItem:self.toolBarThumbCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90.0];
        [self.toolBarThumbCollectionView addConstraint:heightConstraint1];
        
        NSLayoutConstraint *rightConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15.0];
        NSLayoutConstraint *topConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0];
        [self.toolBar addConstraints:@[rightConstraint2, topConstraint2]];
        
        NSLayoutConstraint *widthConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:190*0.5];
        NSLayoutConstraint *heightConstraint2 = [NSLayoutConstraint constraintWithItem:self.completeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];
        [self.completeBtn addConstraints:@[widthConstraint2, heightConstraint2]];
        
        NSLayoutConstraint *leftConstraint3 = [NSLayoutConstraint constraintWithItem:self.haveSelectedLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0];
        NSLayoutConstraint *topConstraint3 = [NSLayoutConstraint constraintWithItem:self.haveSelectedLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0];
        [self.toolBar addConstraints:@[leftConstraint3, topConstraint3]];
        
        NSLayoutConstraint *widthConstraint3 = [NSLayoutConstraint constraintWithItem:self.haveSelectedLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35.f];
        NSLayoutConstraint *heightConstraint3 = [NSLayoutConstraint constraintWithItem:self.haveSelectedLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];
        [self.haveSelectedLabel addConstraints:@[widthConstraint3, heightConstraint3]];
        
        NSLayoutConstraint *leftConstraint4 = [NSLayoutConstraint constraintWithItem:self.allCountLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.haveSelectedLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *topConstraint4 = [NSLayoutConstraint constraintWithItem:self.allCountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.toolBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0];
        [self.toolBar addConstraints:@[leftConstraint4, topConstraint4]];
        
        NSLayoutConstraint *widthConstraint4 = [NSLayoutConstraint constraintWithItem:self.allCountLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:110.f];
        NSLayoutConstraint *heightConstraint4 = [NSLayoutConstraint constraintWithItem:self.allCountLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];
        [self.allCountLabel addConstraints:@[widthConstraint4, heightConstraint4]];
        
    }
    
    NSArray *collectionViewConstraints =  [self.view constraintsReferencingView:self.collectionView];
    [self.collectionView removeMatchingConstraints:collectionViewConstraints];
    
    NSLayoutConstraint *leftConstraint5 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint5 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint5 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint5 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-bottomCons-insets.bottom];
    [self.view addConstraints:@[leftConstraint5, topConstraint5, rightConstraint5, bottomConstraint5]];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(5.0, insets.left, 5.0, insets.right);
    
    CGFloat width = self.view.bounds.size.width-insets.left-insets.right;
    CGFloat cellW = (width - CYPhotoCenter.config.minimumInteritemSpacing * (CYPhotoCenter.config.columnNumber - 1)) / CYPhotoCenter.config.columnNumber;
    _collectionLayout.itemSize = CGSizeMake(cellW, cellW);
    _collectionLayout.minimumInteritemSpacing = CYPhotoCenter.config.minimumInteritemSpacing;
    _collectionLayout.minimumLineSpacing = CYPhotoCenter.config.minimumLineSpacing;
    if (CYPhotoCenter.config.showCountFooter) {
        _collectionLayout.footerReferenceSize = CGSizeMake(width, 44 * 2);
    }
    [self.collectionView setCollectionViewLayout:_collectionLayout];
    
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_collectionLayout.itemSize.height + _collectionLayout.minimumLineSpacing);
        [_collectionView setContentOffset:CGPointMake(0, offsetY)];
        
        _offsetItemCount = 0;
    }
}

- (void)setupUI {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    
    if (CYPhotoCenter.config.isSinglePick) {
        
    } else {
        // 初始化底部ToorBar
        [self setupToorBar];
    }
}

- (void)scrollBottomCollectionViewToLast {
    if ([CYPhotoCenter shareCenter].selectedPhotos.count > 0) {
        NSInteger item = [CYPhotoCenter shareCenter].selectedPhotos.count-1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.toolBarThumbCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        });
    }
}

- (void)scrollCollectionViewToBottom {
    if (self.shouldScrollToBottom && self.assets.count > 0) {
        NSInteger item = 0;
        if (CYPhotoCenter.config.ascending) {
            item = self.assets.count - 1;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            self.shouldScrollToBottom = NO;
            self.collectionView.hidden = NO;
        });
    } else {
        self.collectionView.hidden = NO;
    }
}

- (void)refreshBottomView:(BOOL)isScrollToLast {
    
    // 取消隐式动画
    [UIView performWithoutAnimation:^{
        [self.toolBarThumbCollectionView reloadData];
    }];
    
    self.allCountLabel.text = [NSString stringWithFormat:@"%ld/%ld张", (long)[CYPhotoCenter shareCenter].selectedPhotos.count, (long)[CYPhotoCenter shareCenter].config.maxSelectedCount];
    
    if (isScrollToLast) {
        [self scrollBottomCollectionViewToLast];
    }

    if ([CYPhotoCenter shareCenter].selectedPhotos.count > 0) {
        self.completeBtn.hidden = NO;
    } else {
        self.completeBtn.hidden = YES;
    }
}

#pragma mark -初始化底部ToorBar
- (void)setupToorBar {
    UIView *toolBar = [[UIView alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    self.toolBar.backgroundColor = [UIColor whiteColor];
   
    self.toolBarThumbCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.toolBarThumbCollectionView];

    self.completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.completeBtn];
    
    self.haveSelectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.haveSelectedLabel];

    self.allCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.allCountLabel];
   
}

#pragma mark - getters and setters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceHorizontal = NO;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoAssetCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([CYPhotoAssetCell class])];
        if (CYPhotoCenter.config.showCountFooter) {
            [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoAssetsFooter class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([CYPhotoAssetsFooter class])];
        }
    }
    return _collectionView;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.layer.cornerRadius = 25/2;
        _completeBtn.layer.masksToBounds = YES;
        [_completeBtn setBackgroundColor:CYPHOTOLIB_COMPLETE_BTN_BG_COLOR];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _completeBtn.enabled = YES;
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _completeBtn.frame = CGRectMake(CYPHOTOLIB_SCREEN_W-220/2, 12, 190/2, 25);
        [_completeBtn setTitle:[NSBundle cy_localizedStringForKey:@"Star Making"] forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        _completeBtn.hidden = YES;
    }
    return _completeBtn;
}

- (UILabel *)haveSelectedLabel {
    if (!_haveSelectedLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 35, 25)];
        label.text = @"已选";
        label.textColor = [UIColor colorWithRed:0.302 green:0.294 blue:0.298 alpha:1.000];
        label.font = [UIFont systemFontOfSize:16];
        self.haveSelectedLabel = label;
    }
    return _haveSelectedLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 12, 110, 25)];
        label.text = [NSString stringWithFormat:@"（%@-%@张）", @([CYPhotoCenter shareCenter].config.minSelectedCount), @([CYPhotoCenter shareCenter].config.maxSelectedCount)];
        label.textColor = [UIColor colorWithRed:0.302 green:0.294 blue:0.298 alpha:1.000];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        self.numberLabel = label;
    }
    return _numberLabel;
}

- (UILabel *)allCountLabel {
    if (!_allCountLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 12, 110, 25)];
        label.text = [NSString stringWithFormat:@"/%@张", @([CYPhotoCenter shareCenter].config.maxSelectedCount)];
        label.textColor = [UIColor colorWithRed:0.302 green:0.294 blue:0.298 alpha:1.000];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        self.allCountLabel = label;
    }
    return _allCountLabel;
}

- (UICollectionView *)toolBarThumbCollectionView {
    if (!_toolBarThumbCollectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(90, 90);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //FIXME:
        //!!!: toolBar上的collectionView
        // CGRectMake(0, 22, 300, 44)
        UICollectionView *toolBarThumbCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, CYPHOTOLIB_SCREEN_W, 90) collectionViewLayout:flowLayout];
        toolBarThumbCollectionView.backgroundColor = [UIColor clearColor];
        toolBarThumbCollectionView.scrollsToTop = NO;
        toolBarThumbCollectionView.dataSource = self;
        toolBarThumbCollectionView.delegate = self;
        [toolBarThumbCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoBottomCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([CYPhotoBottomCollectionViewCell class])];
        
        _toolBarThumbCollectionView = toolBarThumbCollectionView;
    }
    return _toolBarThumbCollectionView;
}

@end
