//
//  CYPhotoAssetsController.m
//  PhotoLibDemo
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
#import "UIView+CYConstraintMatching.h"

#import "CYAlbum.h"
#import "CYAsset.h"
#import "CYPhotoHud.h"
#import "CYPhotoConfig.h"

#import "NSBundle+CYPhotoLib.h"


static CGFloat TOOLBAR_HEIGHT = 135;


@interface CYPhotoAssetsController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    CGFloat _offsetItemCount;
}

@property (nonatomic, assign) BOOL shouldScrollToBottom; // 是否滚到底

@property (strong, nonatomic) UIView *bottomView; //底部面板
@property (strong, nonatomic) UIButton *isOriginalBtn; //原图按钮
@property (strong, nonatomic) UIView *bottomViewCover; //底部面板遮罩层
@property (strong, nonatomic) UILabel *comBtn; //完成按钮
@property (strong, nonatomic) UIButton *completeBtn; //完成按钮

// 已选
@property (nonatomic, strong) UILabel *haveSelectedLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *allCountLabel;

// 标记View
@property (nonatomic , weak  ) UILabel   *makeView;
@property (nonatomic , strong) UIButton  *doneBtn;

// UIToolbar 目测以后只能用 items了。上面盖了一层东西
//@property (nonatomic , weak  ) UIToolbar *toolBar;
@property (nonatomic , strong) UIView *toolBar;
// 底部CollectionView
@property (nonatomic , weak) UICollectionView *toolBarThumbCollectionView;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;

@property (nonatomic , strong) CYPhotoAssetsFooter *footerView;

@property (nonatomic, strong) NSMutableArray<CYAsset *> *dataSource;

@property (nonatomic, copy) NSString * collectionTitle;
@property (nonatomic, strong) NSMutableArray<CYAsset *> *assets;

@end

@implementation CYPhotoAssetsController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionTitle = self.album.name;
    self.title = self.collectionTitle ? self.collectionTitle : [NSBundle cy_localizedStringForKey:@"Photos"];
    
    self.shouldScrollToBottom = YES;
    
    [self setupUI];
    
    self.collectionView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self fetchAssets];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshBottomView];
    [self.collectionView reloadData];
}

- (void)fetchAssets {
    CYPhotoHud *hud = [CYPhotoHud hud];
    
    if (!_assets.count) {
        [hud showProgressHUD];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!self.album) {
            [[CYPhotoManager manager] fetchCameraRollAlbumAllowPickingVideo:NO allowPickingImage:YES needFetchAssets:YES sortByModificationDate:CYPhotoCenter.config.sortByModificationDate ascending:CYPhotoCenter.config.ascending completion:^(CYAlbum *model) {
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
            [[CYPhotoManager manager] fetchAssetsFromFetchResult:self.album.result completion:^(NSArray<CYAsset *> *array) {
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self someLayout];
}

- (void)viewSafeAreaInsetsDidChange {
//    NSLog(@"old - safeAreaInserts ------------------ %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
//
    [super viewSafeAreaInsetsDidChange];
    
//    NSLog(@"new - safeAreaInserts ------------------ %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
}

//- (BOOL)prefersHomeIndicatorAutoHidden {
//    // 自动隐藏 HommeIndicator
//    return YES;
//}

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

#pragma mark - collectionView delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.toolBarThumbCollectionView) {
        return [CYPhotoCenter shareCenter].selectedPhotos.count;
    }
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.toolBarThumbCollectionView) {
    
        NSMutableArray *arr = [CYPhotoCenter shareCenter].selectedPhotos;
        CYAsset *asset = arr[indexPath.item];
        
        CYPhotoBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CYPhotoBottomCollectionViewCell class]) forIndexPath:indexPath];
        
        cell.indexPath = indexPath;
        cell.asset = asset;
        
        [[CYPhotoManager manager] fetchImageWithAsset:asset.asset photoWidth:cell.bounds.size.width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
            cell.imageView.image = image;
        }];
        
        __weak typeof(self)weakSelf = self;
        
        [cell setDeleteTapBlock:^(NSIndexPath *cellIndexPath, CYAsset *ast) {
            __strong typeof(self)strongSelf = weakSelf;
            [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:cellIndexPath.item];
            
            // delete 刷新
//            BOOL isContent = NO;
            for (CYAsset *model in strongSelf.dataSource) {
                if ([model.asset.localIdentifier isEqualToString:ast.asset.localIdentifier]) {
//                    isContent = YES;
                    
                    NSInteger ind = [strongSelf.dataSource indexOfObject:model];
                    NSIndexPath *p = [NSIndexPath indexPathForItem:ind inSection:indexPath.section];
                    [strongSelf.collectionView reloadItemsAtIndexPaths:@[p]];
                }
            }
//            if (isContent) {
//                NSInteger ind = [strongSelf.dataSource indexOfObject:ast];
//                NSIndexPath *p = [NSIndexPath indexPathForItem:ind inSection:indexPath.section];
//                [strongSelf.collectionView reloadItemsAtIndexPaths:@[p]];
//            }
            
            [strongSelf refreshBottomView];
        }];
        
        return cell;
    } else {
        CYPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CYPhotoAssetCell class]) forIndexPath:indexPath];
        
        cell.asset = self.dataSource[indexPath.item].asset;
        
        cell.singleSelBtn.hidden = !CYPhotoCenter.config.isSinglePick;
        
        BOOL isContent = NO;
        for (CYAsset *model in [CYPhotoCenter shareCenter].selectedPhotos) {
            if ([model.asset.localIdentifier isEqualToString:self.dataSource[indexPath.item].asset.localIdentifier]) {
                isContent = YES;
            }
        }

        cell.selBtn.selected = isContent;
        
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
                NSUInteger index = 0;
                for (CYAsset *model in [CYPhotoCenter shareCenter].selectedPhotos) {
                    if ([model.asset.localIdentifier isEqualToString:self.dataSource[indexPath.item].asset.localIdentifier]) {
                        index = [[CYPhotoCenter shareCenter].selectedPhotos indexOfObject:model];
                    }
                }
                
                [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:index];
            }
            [weakSelf refreshBottomView];
            
        }];
    
//        [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(kScreenW, kScreenH) isResize:NO completion:^(UIImage *image, NSDictionary *info) {
//            [cell setImgTapBlock:^{
//                UIImageView *lastView = [weakCell.contentView.subviews lastObject];
//                [CYHeadImageToBig showImage:lastView withImage:image];
//            }];
//        }];

        [cell setImgTapBlock:^{
//            UIImageView *lastView = [weakCell.contentView.subviews lastObject];
//            [CYHeadImageToBig showImage:lastView withImage:weakCell.imageIV.image];
        }];
        
        // 如果是单张图片选择
        [cell setSigleSelectedBlock:^(BOOL isSelected) {
            
            NSLog(@"单张图片选择完成");
            
            [[CYPhotoCenter shareCenter].selectedPhotos addObject:weakSelf.dataSource[indexPath.item]];
            
            [[CYPhotoCenter shareCenter] endPick];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [cell setUnableTapBlock:^{
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"不可选择" message:@"图片不符合制作规定" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        
        [cell setLowInfoTapBlock:^{
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
    self.footerView = footerView;
    return reusableView;
}

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
- (void)setupUI {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    
    if (CYPhotoCenter.config.isSinglePick) {
//        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
        // 初始化按钮
//        [self setupButtonsSingle];
    } else {
        
        // 初始化按钮
//        [self setupButtons];
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

- (void)setupButtons {
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBtnAction)];
}

- (void)setupButtonsSingle {
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(completeClick:)];
}

//- (void)loadAssetData {
//
//    [[CYPhotoManager manager] fetchAssetsInCollection:self.assetCollection asending:NO completion:^(NSArray<PHAsset *> *assets) {
//        self.dataSource = assets;
//    }];
//}

- (void)refreshBottomView {
    
    // 取消隐式动画
    [UIView performWithoutAnimation:^{
        [self.toolBarThumbCollectionView reloadData];
    }];
    
    self.allCountLabel.text = [NSString stringWithFormat:@"%ld/%ld张", (long)[CYPhotoCenter shareCenter].selectedPhotos.count, (long)[CYPhotoCenter shareCenter].config.maxSelectedCount];
    
    [self scrollBottomCollectionViewToLast];

    if ([CYPhotoCenter shareCenter].selectedPhotos.count > 0) {
        //        self.bottomViewCover.hidden = YES;
//        self.isOriginalBtn.selected = [CYPhotoCenter shareCenter].isOriginal;
        //        self.comBtn.text = [NSString stringWithFormat:@"完成(%zi)", [CYPhotoCenter shareCenter].selectedPhotos.count];
        
        self.completeBtn.hidden = NO;
    } else {
        //        self.bottomViewCover.hidden = NO;
        self.isOriginalBtn.selected = NO;
        //        self.comBtn.text = @"完成";
        
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
   
//    //!!!: 这里设置的toolBar
//    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
//    NSString *widthVfl =  @"H:|-0-[toolBar]-0-|";
//    NSString *heightVfl = @"V:[toolBar(135)]-0-|";
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    self.toolBarThumbCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.toolBarThumbCollectionView];

    self.completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.completeBtn];
    
    self.haveSelectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.haveSelectedLabel];

    //!!!: Cyrill:这里是计数的样式
    //    if (self.isCalendar) {
    self.allCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolBar addSubview:self.allCountLabel];
    //    } else {
    //        [self.toolBar addSubview:self.numberLabel];
    //    }
    
    
//    if (@available(iOS 11, *)) {
//        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
//
//        [NSLayoutConstraint activateConstraints:@[[self.toolBar.topAnchor constraintEqualToSystemSpacingBelowAnchor:guide.topAnchor multiplier:1.0],[self.toolBar.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:guide.bottomAnchor multiplier:1.0],]];
//    }

    // 左视图 中间距 右视图
    //    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.tbLeftView];
    //    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.tbRightView];
    //
    //    toorBar.items = @[leftItem,fiexItem,rightItem];
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CYPHOTOLIB_SCREEN_H-50, CYPHOTOLIB_SCREEN_W, 50)];
    }
    return _bottomView;
}

- (UIView *)bottomViewCover {
    if (!_bottomViewCover) {
        _bottomViewCover = [[UIView alloc] init];
        _bottomViewCover.frame = self.bottomView.frame;
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
//        UIView *sendView = [[UIView alloc] initWithFrame:CGRectMake(CYPHOTOLIB_SCREEN_W-70-14, 5, 70, 30)];
//        sendView.backgroundColor = [UIColor grayColor];
//        _comBtn.frame = sendView.bounds;
//        [sendView addSubview:_comBtn];
//
//        [sendView addSubview:self.completeBtn];
//        
////        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
////        btn.frame = sendView.bounds;
////        [btn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
////        [sendView addSubview:btn];
//        
//        [self.bottomView addSubview:sendView];
    }
    return _comBtn;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rightBtn setBackgroundImage:[UIImage imageNamed:@"icon_zhizuo"] forState:UIControlStateNormal];
//        [rightBtn setBackgroundImage:[UIImage imageNamed:@"icon_zhizuo_unsel"] forState:UIControlStateDisabled];
//        [_completeBtn setBackgroundColor:[UIColor grayColor]];
        
        _completeBtn.layer.cornerRadius = 25/2;
        _completeBtn.layer.masksToBounds = YES;
        [_completeBtn setBackgroundColor:CYPHOTOLIB_COMPLETE_BTN_BG_COLOR];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _completeBtn.enabled = YES;
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _completeBtn.frame = CGRectMake(CYPHOTOLIB_SCREEN_W-220/2, 12, 190/2, 25);
        [_completeBtn setTitle:@"开始制作" forState:UIControlStateNormal];
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

#pragma mark - receive and dealloc

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
//    self.collectionView.dataSource = nil;
//    self.collectionView.delegate = nil;
//    self.collectionView = nil;
//    self.dataSource = nil;
}

@end
