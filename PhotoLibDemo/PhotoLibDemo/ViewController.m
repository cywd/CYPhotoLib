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

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.imageView.image = self.dataArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin = 10;
    CGFloat itemWidth = (width-3*margin-3)/2;
    return CGSizeMake(itemWidth, itemWidth);
}
#pragma mark - custom delegate

#pragma mark - reuseable methods

#pragma mark - event response
- (IBAction)btnClick:(UIButton *)sender {
    
    [self gotoPhotos];
}

- (IBAction)clear:(UIButton *)sender {
    [self.dataArray removeAllObjects];
    [[CYPhotoCenter shareCenter] clearInfos];
    [self.collectionView reloadData];
}

#pragma mark - private methods
- (void)gotoPhotos {
    __weak typeof(self) weakSelf = self;
    CYPhotoPicker *picker = [[CYPhotoPicker alloc] init];
    [picker showInSender:self isSingleSel:NO handle:^(NSArray<UIImage *> *photos, NSArray<PHAsset *> *assets) {
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:photos];
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - getters and setters
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - receive and dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
