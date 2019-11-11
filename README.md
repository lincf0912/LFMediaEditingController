# LFMediaEditingController

[English](https://github.com/lincf0912/LFMediaEditingController/blob/master/README_EN.md)

* 图片编辑 (详细使用见LFPhotoEditingController.h 的初始化方法)
`绘画、贴图、文本、模糊、滤镜（iOS9）、修剪`

* 视频编辑 (详细使用见LFVideoEditingController.h 的初始化方法)
`绘画、贴图、文本、音频、剪辑、滤镜（iOS9）、速率（慢动作）`

* 视频编辑 需要访问音乐库 需要在info.plist 添加 NSAppleMusicUsageDescription
* 支持国际化配置（复制LFMediaEditingController.bundle\LFMediaEditingController.strings到项目中，修改对应的值即可；详情见DEMO；注意：不跟随系统语言切换显示）
* （因数据可以多次重复编辑，暂时未能处理横竖屏切换。）

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

## 图片展示

![image](https://github.com/lincf0912/LFMediaEditingController/blob/master/ScreenShots/screenshot.gif)


* 视频编辑
* LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
* lfVideoEditVC.delegate = self;
* if (self.videoEdit) {
* lfVideoEditVC.videoEdit = self.videoEdit;
* } else {
* [lfVideoEditVC setVideoURL:self.url placeholderImage:nil];
* }
* [self.navigationController setNavigationBarHidden:YES]; //隐藏导航栏（方式因项目自身适配）
* [self.navigationController pushViewController:lfPhotoEditVC animated:NO]; 

## 视频展示

![image](https://github.com/lincf0912/LFMediaEditingController/blob/master/ScreenShots/screenshot_video.gif)


