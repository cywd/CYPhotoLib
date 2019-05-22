//
//  ViewController.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/6/20.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "ViewController.h"
#import "CYPhotoLib.h"
#import "CollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<CYPhotoAsset *> *assets;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _assets = [NSMutableArray array];
}

#pragma mark - collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.coverView.hidden = !(self.dataArray.count == 0);
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    
    PHAsset *asset = self.dataArray[indexPath.item];
    [CYPhotoManager fetchImageWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        cell.imageView.image = image;
    }];
//    [CYPhotoManager fetchOriginalImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
//        cell.imageView.image = image;
//    }];
    
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat margin = 10;
//    CGFloat itemWidth = (width-3*margin-3)/2;
//    return CGSizeMake(itemWidth, itemWidth);
//}
#pragma mark - custom delegate

#pragma mark - reuseable methods

#pragma mark - event response
- (IBAction)btnClick:(UIButton *)sender {
    
    CYPhotoPicker *picker = [[CYPhotoPicker alloc] init];
    picker.columnNumber = 4;
    picker.ascending = YES;
    // 100 warning 70k disabled 6M 6,144kb
    // 不可选70k 下，20M 以上
    picker.minDisabledDataLength = 70;
    picker.maxDisabledDataLength = 15*1024;
    // 警告 100k 下
    picker.minWarningDataLength = 100;
    // 警告 宽高比 2:1 或者 1:2
    picker.warningAspectRatio = 2;
    
    [picker showInSender:self handler:^(NSArray<PHAsset *> *assets) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[assets copy]];
        
        self.dataArray = [arr copy];
        arr = nil;
        [self.collectionView reloadData];
        
    }];
}

- (IBAction)clear:(UIButton *)sender {
    
    self.dataArray = nil;
    self.dataArray = [NSMutableArray array];
    [[CYPhotoCenter shareCenter] clearInfos];
    [self.collectionView reloadData];
}

#pragma mark - private methods
- (void)showEmptyView {
    
}

#pragma mark - getters and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - receive and dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
