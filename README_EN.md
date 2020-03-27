# LFMediaEditingController


[中文](https://github.com/lincf0912/LFMediaEditingController/blob/master/README.md)

* Image editing (see LFPhotoEditingController.h for details)
`Draw, Sticker, Text, Blur, Filters (iOS9), Crop`

* Video editing (see LFVideoEditingController.h for details)
`Draw、Sticker、Text、Auidio、Clip、Filter（iOS9）、Rate（slow motion）`

* Video editing needs to access the music library, you need to add NSAppleMusicUsageDescription in info.plist

* Support for i18n configuration. (copy LFMediaEditingController.bundle\ LFMediaEditingController.strings to your project and modify the corresponding value. For more information, see DEMO; Note: it does not follow the system language switch display.)

* Does not support interface orientation.

## Installation

* CocoaPods：`pod 'LFMediaEditingController'`
* `#import "LFPhotoEditingController.h"`
* `#import "LFVideoEditingController.h"`

## Photo Demonstration

* LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
* lfPhotoEditVC.delegate = self;
* if (self.photoEdit) {
*   lfPhotoEditVC.photoEdit = self.photoEdit;
* } else {
*   lfPhotoEditVC.editImage = self.imageView.image;
* }
* [self.navigationController setNavigationBarHidden:YES]; //Hide the navigation bar
* [self.navigationController pushViewController:lfPhotoEditVC animated:NO]; 

## Presentation

![image](https://github.com/lincf0912/LFMediaEditingController/blob/master/ScreenShots/screenshot.gif)


## Video Demonstration
* LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
* lfVideoEditVC.delegate = self;
* if (self.videoEdit) {
* lfVideoEditVC.videoEdit = self.videoEdit;
* } else {
* [lfVideoEditVC setVideoURL:self.url placeholderImage:nil];
* }
* [self.navigationController setNavigationBarHidden:YES]; //Hide the navigation bar
* [self.navigationController pushViewController:lfPhotoEditVC animated:NO]; 

## Presentation

![image](https://github.com/lincf0912/LFMediaEditingController/blob/master/ScreenShots/screenshot_video.gif)


