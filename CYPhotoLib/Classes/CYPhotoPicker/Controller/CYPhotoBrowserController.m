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
@property (nonatomic, strong) UILabel *yixuanLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *allCountLabel;

// 标记View
@property (nonatomic , weak  ) UILabel   *makeView;
@property (nonatomic , strong) UIButton  *doneBtn;

@property (nonatomic , weak  ) UIToolbar *toolBar;
// 底部CollectionView
@property (nonatomic , weak) UICollectionView *toolBarThumbCollectionView;

@property (nonatomic, strong) UICollectionView * collectionView;

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
    
    [self setupUI];
    
    [self loadAssetData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshBottomView];
    [self.collectionView reloadData];
    
    
    [self.toolBar addSubview:self.yixuanLabel];
    
    //!!!: Cyrill:这里是计数的样式
    //    if (self.isCalendar) {
        [self.toolBar addSubview:self.allCountLabel];
    //    } else {
    //        [self.toolBar addSubview:self.numberLabel];
    //    }
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
        
        [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(cell.w * 2, cell.h * 2) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            cell.imageView.image = image;
        }];
        
        __weak typeof(self)weakSelf = self;
        
        [cell setDeleteTapBlock:^(NSIndexPath *cellIndexPath) {
            
            [[CYPhotoCenter shareCenter].selectedPhotos removeObjectAtIndex:cellIndexPath.item];
            
            [weakSelf.collectionView reloadData];
            
            [weakSelf refreshBottomView];
        }];
        
        return cell;
        
        
    } else {
    
        CYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"browserCell" forIndexPath:indexPath];
        
        PHAsset *asset = self.dataSource[indexPath.item];
        
        CGFloat width = asset.pixelWidth;
        CGFloat height = asset.pixelHeight;
        
        cell.singleSelBtn.hidden = !_isSingleSel;
        
        cell.selBtn.hidden = YES;
        cell.tanhao.hidden = YES;
        cell.coverBtn.hidden = YES;
        
        dispatch_async(dispatch_queue_create("CYSetHiddenQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
            // 耗时
            BOOL isLocal = [[CYPhotoManager manager] isInLocalAblumWithAsset:asset];
            if (isLocal && (asset.mediaType == PHAssetMediaTypeImage)) {
                
                [[CYPhotoManager manager] getImageDataLength:asset completeBlock:^(CGFloat length) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
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
                        
                        cell.selBtn.hidden = !cell.coverBtn.hidden;
                        
                        if (!cell.singleSelBtn.hidden) {
                            cell.selBtn.hidden = YES;
                            cell.tanhao.hidden = YES;
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.coverBtn.hidden = NO;
                });
            }
        });

        
        dispatch_async(dispatch_queue_create("CYSetImageQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            // 这里修改了 isResize 为 NO， 设置为YES会闪来闪去的
            [[CYPhotoManager manager] fetchImageInAsset:asset size:CGSizeMake(cell.w * 2, cell.h * 2) isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageIV.image = image;
                });
            }];
        });

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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoBrowserFooter *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        CYPhotoBrowserFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier forIndexPath:indexPath];
        
        footerView.count = self.info.count;
        
        reusableView = footerView;
        self.footerView = footerView;
    } else {
        
    }
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
    
    //    [self.view insertSubview:self.collectionView belowSubview:self.bottomView];
    [self.view addSubview:self.collectionView];
    
    if (_isSingleSel) {
        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
        // 初始化按钮
        [self setupButtonsSingle];
        
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        
        // 初始化按钮
        [self setupButtons];
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
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    self.toolBar.barTintColor = [UIColor whiteColor];
    
    //!!!: 这里设置的toolBar
    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
    NSString *widthVfl =  @"H:|-0-[toolBar]-0-|";
    NSString *heightVfl = @"V:[toolBar(135)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    
    [self.toolBar addSubview:self.toolBarThumbCollectionView];
    [self.toolBar addSubview:self.completeBtn];

    
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
        
        CGFloat cellW = (SCREEN_W - CELL_MARGIN * (CELL_ROW - 1)) / CELL_ROW;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = CELL_INTERRITEM_MARGIN;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, 44 * 2);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_W, SCREEN_H-64) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"CYPhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"browserCell"];
        [_collectionView registerClass:[CYPhotoBrowserFooter class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H-50, SCREEN_W, 50)];
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
//        UIView *sendView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_W-70-14, 5, 70, 30)];
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
        [_completeBtn setBackgroundColor:[UIColor purpleColor]];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _completeBtn.enabled = YES;
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _completeBtn.frame = CGRectMake(SCREEN_W-220/2, 12, 190/2, 25);
        [_completeBtn setTitle:@"开始制作" forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        _completeBtn.hidden = YES;
    }
    return _completeBtn;
}

- (UILabel *)yixuanLabel {
    if (!_yixuanLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 35, 25)];
        label.text = @"已选";
        label.textColor = [UIColor colorWithRed:0.302 green:0.294 blue:0.298 alpha:1.000];
        label.font = [UIFont systemFontOfSize:16];
        self.yixuanLabel = label;
    }
    return _yixuanLabel;
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
        UICollectionView *toolBarThumbCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_W, 90) collectionViewLayout:flowLayout];
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

@end
