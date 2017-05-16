# CYPhotoLib

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/CoderCYLee/CYPhotoLib/blob/master/LICENSE) 
[![CocoaPods](http://img.shields.io/cocoapods/v/CYPhotoLib.svg?style=flat)](http://cocoapods.org/?q=CYPhotoLib) 
[![CocoaPods](http://img.shields.io/cocoapods/p/CYPhotoLib.svg?style=flat)](http://cocoapods.org/?q=CYPhotoLib) 
[![Support](https://img.shields.io/badge/support-iOS%208%2B-blue.svg?style=flat)](https://www.apple.com/nl/ios/) 

PhotoLib是一个基于<Photos>的图片选择库 - OC



结构

```
CYPhotoLib
├── Classes
│   ├── CYPhotoCommon.h
│   ├── CYPhotoConfig.h
│   ├── CYPhotoConfig.m
│   ├── CYPhotoHeader.h
│   ├── CYPhotoLib.h
│   ├── CYPhotoPicker
│   │   ├── Category
│   │   │   ├── NSString+CYPHChineseName.h
│   │   │   ├── NSString+CYPHChineseName.m
│   │   │   ├── UIButton+CYCreate.h
│   │   │   ├── UIButton+CYCreate.m
│   │   │   ├── UIImage+CYCutDown.h
│   │   │   ├── UIImage+CYCutDown.m
│   │   │   ├── UIView+CYAnimation.h
│   │   │   ├── UIView+CYAnimation.m
│   │   │   ├── UIView+CY_1pxLine.h
│   │   │   └── UIView+CY_1pxLine.m
│   │   ├── Controller
│   │   │   ├── CYPhotoAblumListController.h
│   │   │   ├── CYPhotoAblumListController.m
│   │   │   ├── CYPhotoBaseController.h
│   │   │   ├── CYPhotoBaseController.m
│   │   │   ├── CYPhotoBrowserController.h
│   │   │   ├── CYPhotoBrowserController.m
│   │   │   ├── CYPhotoNavigationViewController.h
│   │   │   └── CYPhotoNavigationViewController.m
│   │   ├── Manager
│   │   │   ├── CYPhotoCenter.h
│   │   │   ├── CYPhotoCenter.m
│   │   │   ├── CYPhotoManager.h
│   │   │   └── CYPhotoManager.m
│   │   ├── Model
│   │   │   ├── CYAblumInfo.h
│   │   │   └── CYAblumInfo.m
│   │   └── View
│   │       ├── CYPhotoAblumCell.h
│   │       ├── CYPhotoAblumCell.m
│   │       ├── CYPhotoBottomCollectionViewCell.h
│   │       ├── CYPhotoBottomCollectionViewCell.m
│   │       ├── CYPhotoBottomCollectionViewCell.xib
│   │       ├── CYPhotoBrowserCell.h
│   │       ├── CYPhotoBrowserCell.m
│   │       ├── CYPhotoBrowserCell.xib
│   │       ├── CYPhotoBrowserFooter.h
│   │       ├── CYPhotoBrowserFooter.m
│   │       └── CYPhotoBrowserFooter.xib
│   ├── CYPhotoPicker.h
│   └── CYPhotoPicker.m
└── Resource
    ├── CYBack@2x.png
    ├── CYBack@3x.png
    ├── CYPhoto_Tanhao.png
    ├── CYPhoto_Tanhao@2x.png
    ├── CYPhoto_Tanhao@3x.png
    ├── CYPhoto_circle@2x.png
    ├── CYPhoto_delete.png
    ├── CYPhoto_delete@2x.png
    ├── CYPhoto_selected.png
    ├── CYPhoto_selected@2x.png
    ├── CYPhoto_selected@3x.png
    ├── CYPhoto_unselected.png
    ├── CYPhoto_unselected@2x.png
    └── CYPhoto_unselected@3x.png

8 directories, 56 files

```

