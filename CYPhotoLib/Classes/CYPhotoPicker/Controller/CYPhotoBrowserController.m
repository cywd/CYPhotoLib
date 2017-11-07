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
#import "CYPhotoBrowserFooter.h"
#import "CYPhotoManager.h"
//#import "CYHeadImageToBig.h"
#import "CYPhotoBottomCollectionViewCell.h"
#import "UIView+CYAnimation.h"
#import "CYPhotoCenter.h"

static CGFloat CELL_ROW = 4;
static CGFloat CELL_MARGIN = 5.0;
static CGFloat CELL_INTERRITEM_MARGIN = 5.0;
static CGFloat CELL_LINE_MARGIN = 5.0;
static CGFloat TOOLBAR_HEIGHT = 135;

static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";

@interface CYPhotoBrowserController ()<UICollectionViewDataSource, UICollectionViewDelegate>

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

@property (nonatomic , strong) CYPhotoBrowserFooter *footerView;


@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation CYPhotoBrowserController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CYPhotoCenter shareCenter].maxSelectedCount == 0) {
        [CYPhotoCenter shareCenter].maxSelectedCount = 20;
    }
    
//    [self.view addSubview:_bottomView];
    
    self.title = self.collectionTitle ? self.collectionTitle : @"照片";
    
//    [self setNavigationTitle:self.collectionTitle ? self.collectionTitle : @"相机胶卷"];
    
    // 滑动的时候隐藏navigation bar
//    self.navigationController.hidesBarsOnSwipe = YES;
    
    // 消除导航条返回键带的title
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
//    if (@available(iOS 11, *)) {
//        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
//        [NSLayoutConstraint activateConstraints:@[[self.collectionView.topAnchor constraintEqualToSystemSpacingBelowAnchor:guide.topAnchor multiplier:1.0],[self.collectionView.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:guide.bottomAnchor multiplier:1.0],]];
//    } else {
//        let standardSpacing: CGFloat = 8.0
//        NSLayoutConstraint.activate([
//                                     greenView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
//                                     bottomLayoutGuide.topAnchor.constraint(equalTo: greenView.bottomAnchor, constant: standardSpacing)
//                                     ])
//    }
    
    [self setupUI];
    [self loadAssetData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshBottomView];
    [self.collectionView reloadData];
    
    
//    [self.toolBar addSubview:self.haveSelectedLabel];
//
//    //!!!: Cyrill:这里是计数的样式
//    //    if (self.isCalendar) {
//        [self.toolBar addSubview:self.allCountLabel];
//    //    } else {
//    //        [self.toolBar addSubview:self.numberLabel];
//    //    }
    
//    CYPHOTOLIB_ViewSafeAreInsets
//    CYPHOTOLIB_TabbarSafeBottomMargin
}

- (void)removeToolBarLayout {
    [self.toolBar removeConstraints:self.toolBar.constraints];
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if ([constraint.firstItem isEqual:self.toolBar]) {
            [self.view removeConstraint:constraint];
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
    
    
    UIEdgeInsets insets = CYPHOTOLIB_ViewSafeAreInsets(self.view);
    
    
    CGFloat bottomH = 0;
    CGFloat bottomCons = 0;
    
    if (_isSingleSel) {
        bottomH = 5.0;
    } else {
        bottomH = TOOLBAR_HEIGHT;
        bottomCons = TOOLBAR_HEIGHT;
        
        [self removeToolBarLayout];
        
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
    
//    self.collectionView.contentInset = UIEdgeInsetsMake(5, insets.left, bottomH, insets.right);
    
    self.collectionView.contentInset = UIEdgeInsetsMake(5.0, insets.left, 5.0, insets.right);
    
    CGFloat width = 0.0;

    width = self.view.bounds.size.width-insets.left-insets.right;
    
    
//
//    if (@available(iOS 11, *)) {
//        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
//
//        NSLog(@"guide - %@", guide);
//
//        width = guide.layoutFrame.size.width;
//
//        [NSLayoutConstraint activateConstraints:@[[self.collectionView.topAnchor constraintEqualToSystemSpacingBelowAnchor:guide.topAnchor multiplier:1.0],[self.collectionView.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:guide.bottomAnchor multiplier:1.0],[self.collectionView.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:guide.leadingAnchor multiplier:1.0],[self.collectionView.trailingAnchor constraintEqualToSystemSpacingAfterAnchor:guide.trailingAnchor multiplier:1.0]]];
//    } else {
    
//        width = self.view.bounds.size.width;
    
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-bottomCons-insets.bottom];
        [self.view addConstraints:@[leftConstraint, topConstraint, rightConstraint, bottomConstraint]];
    
    
//    }
    
    CGFloat cellW = (width - CELL_MARGIN * (CELL_ROW - 1)) / CELL_ROW;
    
    _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionLayout.itemSize = CGSizeMake(cellW, cellW);
    _collectionLayout.minimumInteritemSpacing = CELL_INTERRITEM_MARGIN;
    _collectionLayout.minimumLineSpacing = CELL_LINE_MARGIN;
    _collectionLayout.footerReferenceSize = CGSizeMake(width, 44 * 2);
    
    [self.collectionView setCollectionViewLayout:_collectionLayout];
    
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewSafeAreaInsetsDidChange {
    
    
    
    
    NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    
    NSLog(@"dsd");
    
    
    
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
        
        PHAsset *asset = arr[indexPath.item];
        
        CYPhotoBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
        
        cell.indexPath = indexPath;
        cell.asset = asset;
        
        [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(cell.bounds.size.width * 2, cell.bounds.size.height * 2) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            cell.imageView.image = image;
        }];
        
        __weak typeof(self)weakSelf = self;
        
        [cell setDeleteTapBlock:^(NSIndexPath *cellIndexPath, PHAsset *ast) {
            __strong typeof(self)strongSelf = weakSelf;
            [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:cellIndexPath.item];
            
//            [weakSelf.collectionView reloadData];
            // delete 刷新
            if ([strongSelf.dataSource containsObject:ast]) {
                NSInteger ind = [_dataSource indexOfObject:ast];
                NSIndexPath *p = [NSIndexPath indexPathForItem:ind inSection:indexPath.section];
                [strongSelf.collectionView reloadItemsAtIndexPaths:@[p]];
            }
            
            [strongSelf refreshBottomView];
        }];
        
        return cell;
        
        
    } else {
    
        CYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"browserCell" forIndexPath:indexPath];
        
        cell.asset = self.dataSource[indexPath.item];
        
        cell.singleSelBtn.hidden = !_isSingleSel;

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
    
//        [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(kScreenW, kScreenH) isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
//            [cell setImgTapBlock:^{
//                UIImageView *lastView = [weakCell.contentView.subviews lastObject];
//                [CYHeadImageToBig showImage:lastView withImage:image];
//            }];
//            
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
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CYPhotoBrowserFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier forIndexPath:indexPath];
    
    footerView.count = self.info.count;
    
    CYPhotoBrowserFooter *reusableView = footerView;
    self.footerView = footerView;
    return reusableView;
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
    
    

    
    if (_isSingleSel) {
//        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
        // 初始化按钮
//        [self setupButtonsSingle];
        
    } else {
//        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        
        // 初始化按钮
//        [self setupButtons];
        // 初始化底部ToorBar
        [self setupToorBar];
    }
}

- (void)setupButtons{
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBtnAction)];
}

- (void)setupButtonsSingle{
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(completeClick:)];
}

- (void)loadAssetData {
    self.dataSource = [[CYPhotoManager manager] fetchAssetsInCollection:self.assetCollection asending:NO];
    //    [self.collectionView reloadData];
}

- (void)refreshBottomView {
    
    [self.toolBarThumbCollectionView reloadData];
    
    self.allCountLabel.text = [NSString stringWithFormat:@"%zd/%zd张", [CYPhotoCenter shareCenter].selectedPhotos.count,[CYPhotoCenter shareCenter].maxSelectedCount];
    
    
    
    if ([CYPhotoCenter shareCenter].selectedPhotos.count > 0) {
        //        self.bottomViewCover.hidden = YES;
        self.isOriginalBtn.selected = [CYPhotoCenter shareCenter].isOriginal;
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
    
//    (45, 12, 110, 25)
    
    
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
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_collectionLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"CYPhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"browserCell"];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoBrowserFooter class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CYPHOTOLIB_SCREEN_H-50, CYPHOTOLIB_SCREEN_W, 50)];
//        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIView *)bottomViewCover {
    if (!_bottomViewCover) {
        _bottomViewCover = [[UIView alloc] init];
        _bottomViewCover.frame = self.bottomView.frame;
//        [self.view insertSubview:_bottomViewCover aboveSubview:self.bottomView];
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
        label.text = [NSString stringWithFormat:@"（%zd-%zd张）", [CYPhotoCenter shareCenter].minSelectedCount, [CYPhotoCenter shareCenter].maxSelectedCount];
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
        label.text = [NSString stringWithFormat:@"/%zd张", [CYPhotoCenter shareCenter].maxSelectedCount];
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
        [toolBarThumbCollectionView registerNib:[UINib nibWithNibName:@"CYPhotoBottomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:_identifier];
        
        _toolBarThumbCollectionView = toolBarThumbCollectionView;
    }
    return _toolBarThumbCollectionView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
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
