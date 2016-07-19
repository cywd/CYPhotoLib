//
//  CYPhotoPicker.m
//  PhotoLibDemo
//
//  Created by Cyrill on 16/7/18.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import "CYPhotoPicker.h"

@interface CYPhotoPicker ()<UICollectionViewDataSource,
                            UICollectionViewDelegate,
                            UICollectionViewDelegateFlowLayout,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate>

//背景
@property (nonatomic, strong) UIView * bgView;
//图片Sheet
@property (nonatomic, strong) UIView * photoSheet;
//图片列表
@property (nonatomic, strong) UICollectionView * collectionView;
//collectionView数据源
@property (nonatomic, strong) NSArray * dataSource;
//相机按钮
@property (nonatomic, strong) UIButton * cameraBtn;
//发送按钮
@property (nonatomic, strong) UIButton * doneBtn;
//原图按钮
@property (nonatomic, strong) UIButton * originalBtn;
//显示选择器的控制器
@property (nonatomic, weak) UIViewController * sender;

@end

@implementation CYPhotoPicker

- (instancetype)init
{
    if (self = [super init]) {
        [self configData];
        [self configUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#pragma mark - UI
- (void)configData {
    
}

- (void)configUI {
    
    
}

- (void)refreshDoneStatus {
    
}

#pragma mark - 通知处理
- (void)reloadAllPhotos {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.dataSource = [SuPhotoCenter shareCenter].allPhotos;
//        [self.collectionView reloadData];
//    });
}

#pragma mark - 出现和消失
- (void)showInSender:(UIViewController *)sender handle:(void(^)(NSArray<UIImage *> * photos))handle {
    self.sender = sender;
//    [sender.view addSubview:self];
//    [SuPhotoCenter shareCenter].handle = handle;
//    [self.photoSheet showFromBottom];
//    [self.bgView emerge];
    
}

- (void)dismissPhotoPicker {
//    [self.bgView fake];
//    [self.photoSheet dismissToBottomWithCompleteBlock:^{
//        [self removeFromSuperview];
//    }];
}

- (void)dismissPhotoPickerWithoutAni {
    [self removeFromSuperview];
}

#pragma mark - collectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count > self.preViewCount ? self.preViewCount : self.dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    SuPhotoBrowserCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"headCell" forIndexPath:indexPath];
//    [self fetchImageFromAsset:self.dataSource[indexPath.row] completeBlock:^(UIImage *image, NSDictionary *info) {
//        cell.imageIV.image = image;
//        [self changeCellSelBtnPosition];
//    }];
//    cell.selBtn.selected = [[SuPhotoCenter shareCenter].selectedPhotos containsObject:self.dataSource[indexPath.row]];
//    
//    __weak typeof(cell) weakCell = cell;
//    __weak typeof(self) weakSelf = self;
//    [cell setSelectedBlock:^(BOOL isSelected) {
//        if (isSelected) {
//            if ([[SuPhotoCenter shareCenter] isReachMaxSelectedCount]) {
//                weakCell.selBtn.selected = NO;
//                return;
//            }
//            [weakCell.selBtn startSelectedAnimation];
//            [[SuPhotoCenter shareCenter].selectedPhotos addObject:weakSelf.dataSource[indexPath.row]];
//            //调整位置
//            NSInteger photoCount = weakSelf.dataSource.count > weakSelf.preViewCount ? weakSelf.preViewCount : weakSelf.dataSource.count;
//            //取得当前cell的位置
//            CGRect rect = [collectionView convertRect:weakCell.frame fromView:collectionView];
//            CGPoint point = collectionView.contentOffset;
//            float cellEndX = rect.origin.x + rect.size.width - point.x;
//            //滚动到屏幕三分之二处
//            if (cellEndX > SCREEN_W * 2 / 3) {
//                float forwardLen;
//                if (indexPath.item == photoCount - 1) {
//                    forwardLen = cellEndX - SCREEN_W + Space;
//                }else {
//                    forwardLen = cellEndX - SCREEN_W * 2 / 3;
//                }
//                point.x += forwardLen;
//                [collectionView setContentOffset:point animated:YES];
//            }
//        }else {
//            [[SuPhotoCenter shareCenter].selectedPhotos removeObject:weakSelf.dataSource[indexPath.row]];
//        }
//        [weakSelf refreshDoneStatus];
//    }];
//    
//    [cell setImgTapBlock:^{
//        SuPhotoPreviewer * previewer = [[SuPhotoPreviewer alloc]init];
//        if (weakCell.selBtn.selected) {
//            previewer.isPreviewSelectedPhotos = YES;
//        }
//        previewer.selectedAsset = weakSelf.dataSource[indexPath.row];
//        [previewer setBackBlock:^(){
//            [collectionView reloadData];
//            [weakSelf refreshDoneStatus];
//        }];
//        [previewer setDoneBlock:^{
//            [weakSelf dismissPhotoPickerWithoutAni];
//        }];
//        UINavigationController * NVC = [[UINavigationController alloc]initWithRootViewController:previewer];
//        [weakSelf.sender presentViewController:NVC animated:YES completion:nil];
//    }];
//
    
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [self calculateCellSizeFromAsset:self.dataSource[indexPath.row]];
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(0, Space, 0, Space);
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self changeCellSelBtnPosition];
}

#pragma mark - cell相关处理
- (void)changeCellSelBtnPosition {
//    for (SuPhotoBrowserCell * cell in self.collectionView.visibleCells) {
//        //获取每个cell在当前屏幕上的位置
//        CGRect rect = [self convertRect:cell.frame fromView:_collectionView];
//        //获取最右边的cell, 停在屏幕的边上
//        if (rect.origin.x > SCREEN_W - cell.w) {
//            //获取cell里的选择按钮在当前屏幕上的位置
//            CGRect cellRect = [self convertRect:cell.selBtn.frame fromView:cell];
//            //选择按钮在屏幕上固定的位置
//            cellRect.origin.x = SCREEN_W - 25.0 - 1.0 - 5.0;
//            //转化成在cell内的位置
//            cellRect = [self convertRect:cellRect toView:cell];
//            //如果在cell外则固定在左侧，如果在cell里则移动到相应的位置
//            if (cellRect.origin.x < 1.0) {
//                cellRect.origin.x = 1.0;
//            }
//            cell.selBtn.x = cellRect.origin.x;
//        }
//        //如果不是最右边, 则停在cell的右上角
//        else {
//            cell.selBtn.x = cell.w - Space - cell.selBtn.w;
//        }
//    }
}

//- (CGSize)calculateImgSizeFromAsset:(PHAsset *)asset {
//    CGFloat scale = asset.pixelWidth / (CGFloat)asset.pixelHeight;
//    CGFloat imgW = (self.collectionView.h - Space * 2) * scale;
//    CGFloat imgH = self.collectionView.h - Space * 2;
//    return CGSizeMake(imgW * 2, imgH * 2);
//}
//
//- (CGSize)calculateCellSizeFromAsset:(PHAsset *)asset {
//    CGSize size = [self calculateImgSizeFromAsset:asset];
//    return CGSizeMake(size.width / 2, size.height / 2);
//}
//
//- (void)fetchImageFromAsset:(PHAsset *)asset completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
//    CGSize size = [self calculateImgSizeFromAsset:asset];
//    [[SuPhotoManager manager]fetchImageInAsset:asset size:size isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
//        if (completeBlock) completeBlock(image, info);
//    }];
//}

#pragma mark - 相机
- (void)takePhoto {
//    [[SuPhotoCenter shareCenter] cameraAuthoriationValidWithHandle:^{
//        [self launchCamera];
//    }];
}

- (void)launchCamera {
//    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
//    picker.delegate = self;
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [[[UIAlertView alloc]initWithTitle:nil message:@"相机启动失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
//        [self dismissPhotoPicker];
//        return;
//    }
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self.sender presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    //将该图像保存到媒体库中
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
//    //压缩图片 －> 以最长边为屏幕分辨率压缩
//    CGSize size;
//    CGFloat scale = image.size.width / image.size.height;
//    if (scale > 1.0) {
//        if (image.size.width < SCREEN_W) {
//            //最长边小于屏幕宽度时，采用原图
//            size = CGSizeMake(image.size.width, image.size.height);
//        }else {
//            size = CGSizeMake(SCREEN_W, SCREEN_W / scale);
//        }
//    }else {
//        if (image.size.height < SCREEN_H) {
//            //最长边小于屏幕高度时，采用原图
//            size = CGSizeMake(image.size.width, image.size.height);
//        }else {
//            size = CGSizeMake(SCREEN_H * scale, SCREEN_H);
//        }
//        
//    }
//    image = [UIImage imageWithImage:image scaledToSize:size];
//    [[SuPhotoCenter shareCenter] endPickWithImage:image];
//    [self dismissPhotoPickerWithoutAni];
//    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self dismissPhotoPickerWithoutAni];
//    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 相册
- (void)albumBrowser {
//    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
//        UIAlertView * photoLibaryNotice = [[UIAlertView alloc]initWithTitle:@"应用程序无访问照片权限" message:@"请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil];
//        [photoLibaryNotice show];
//        [self dismissPhotoPicker];
//        return;
//    }
//    SuPhotoAblumList * ablumsList = [[SuPhotoAblumList alloc]init];
//    ablumsList.assetCollections = [[SuPhotoManager manager]getAllAblums];
//    UINavigationController * NVC = [[UINavigationController alloc]initWithRootViewController:ablumsList];
//    //默认跳转到照片图册
//    SuPhotoBrowser * browser = [[SuPhotoBrowser alloc]init];
//    [ablumsList.navigationController pushViewController:browser animated:NO];
//    [self dismissPhotoPicker];
//    [self.sender presentViewController:NVC animated:YES completion:nil];
}

- (void)originalSwitch:(UIButton *)sender {
//    self.originalBtn.selected = !self.originalBtn.selected;
//    [SuPhotoCenter shareCenter].isOriginal = sender.selected;
}

#pragma mark - 完成
- (void)endPick {
    
}

#pragma clang diagnostic pop


@end
