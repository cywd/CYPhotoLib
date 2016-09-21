//
//  CYPhotoPreviewerController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPreviewerController.h"
#import "CYPhotoHeader.h"
#import "CYPhotoBrowserCell.h"
#import "CYPhotoManager.h"

@interface CYPhotoPreviewerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, strong) UIButton * selBtn;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation CYPhotoPreviewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)setupUI {
//    if (self.previewPhotos) {
//        self.dataSource = self.previewPhotos.copy;
//    } else if (self.isPreviewSelectedPhotos) {
//        self.dataSource = 
//    }

    self.dataSource = self.previewPhotos.copy;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SCREEN_W, SCREEN_H);
    layout.minimumLineSpacing = 40.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-20, 0, SCREEN_W + 40, SCREEN_H) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CYPhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"headCell"];
    [self.view addSubview:self.collectionView];
    
    self.currentPage = [self.dataSource indexOfObject:self.selectedAsset];
    [self refreshSelBtnStatusWithCurrentPage:(int)self.currentPage];
    [self refreshTitle];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"headCell" forIndexPath:indexPath];
    [[CYPhotoManager manager] fetchImageInAsset:self.dataSource[indexPath.item] size:CGSizeMake(cell.w, cell.h) isResize:NO completeBlock:^(UIImage *image, NSDictionary *info) {
        cell.imageIV.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageIV.image = image;
    }];
    
    cell.tanhao.hidden = YES;
    cell.coverBtn.hidden = YES;
    cell.selBtn.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [cell setImgTapBlock:^{
        [weakSelf refreshHiddenStatus];
    }];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currnt = (int)scrollView.contentOffset.x / self.collectionView.w;
    [self refreshSelBtnStatusWithCurrentPage:currnt];
    [self refreshTitle];
}

- (void)refreshSelBtnStatusWithCurrentPage:(int)page
{    
    self.currentPage = page;
}

- (void)refreshTitle
{
     [self setNavigationTitle:[NSString stringWithFormat:@"%ld / %ld", self.currentPage + 1, self.dataSource.count]];
}

- (void)refreshHiddenStatus
{
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    [UIApplication sharedApplication].statusBarHidden = self.navigationController.navigationBarHidden;
}

@end
