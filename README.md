# LFMediaEditingController

* 图片编辑 (详细使用见LFPhotoEditingController.h 的初始化方法)
* 视频编辑 (详细使用见LFVideoEditingController.h 的初始化方法)

## Installation 安装

* CocoaPods：pod 'LFMediaEditingController'
* 手动导入：将LFMediaEditingController\class文件夹拽入项目中，导入头文件：#import "LFPhotoEditingController.h" #import "LFVideoEditingController.h"

## 调用代码

* 图片编辑
* LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
* lfPhotoEditVC.delegate = self;
* if (self.photoEdit) {
*   lfPhotoEditVC.photoEdit = self.photoEdit;
* } else {
*   lfPhotoEditVC.editImage = self.imageView.image;
* }
* [self.navigationController setNavigationBarHidden:YES]; //隐藏导航栏（方式因项目自身适配）
* [self.navigationController pushViewController:lfPhotoEditVC animated:NO];

* 视频编辑
* 

## 图片展示


