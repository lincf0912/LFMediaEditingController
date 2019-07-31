//
//  PhotoViewController.m
//  LFMediaEditingDEMO
//
//  Created by LamTsanFeng on 2017/6/5.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImage+LF_Format.h"

#import "LFPhotoEditingController.h"

@interface PhotoViewController () <LFPhotoEditingControllerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIImageView *imageView;
/** 需要保存到编辑数据 */
@property (nonatomic, strong) LFPhotoEdit *photoEdit;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
    
    /** 拍照图片 */
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    /** gif */
//    UIImage *image = [UIImage LF_imageWithImagePath:[[NSBundle mainBundle] pathForResource:@"5.gif" ofType:nil]];
    /** 非拍照图片 */
//    UIImage *image = [UIImage imageNamed:@"2.png"];
    /** 长图 */
//    UIImage *image = [UIImage imageNamed:@"longImage.jpg"];
    /** 必须确保图片方向是正确的，当然有很多方法更正图片的方向，这里只是举例，请酌情参考。 */
    if (image.images.count) {
        self.image = image;
    } else {
        /** 普通图片更正方向 */
        self.image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:self.image];
    [self.view addSubview:imageView];
    [imageView startAnimating];
    
    _imageView = imageView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(photoEditing)];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    CGFloat top = self.view.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height;
    self.imageView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y+top, self.view.bounds.size.width, self.view.bounds.size.height-top-self.view.safeAreaInsets.bottom);
}

- (void)photoEditing
{
    LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
//    lfPhotoEditVC.operationType = LFPhotoEditOperationType_draw | LFPhotoEditOperationType_splash;
//    lfPhotoEditVC.defaultOperationType = LFPhotoEditOperationType_crop;
//    lfPhotoEditVC.operationAttrs = @{
//                                     LFPhotoEditDrawColorAttributeName:@(LFPhotoEditOperationSubTypeDrawVioletRedColor),
////                                     LFPhotoEditStickerAttributeName:@"描述（贴图路径）",
//                                     LFPhotoEditTextColorAttributeName:@(LFPhotoEditOperationSubTypeTextAzureColor),
//                                     LFPhotoEditSplashAttributeName:@(LFPhotoEditOperationSubTypeSplashPaintbrush),
//                                     LFPhotoEditFilterAttributeName:@(LFPhotoEditOperationSubTypeProcessFilter),
//                                     LFPhotoEditCropAspectRatioAttributeName:@(LFPhotoEditOperationSubTypeCropAspectRatio1x1)
//                                     };
    lfPhotoEditVC.delegate = self;
    if (self.photoEdit) {
        lfPhotoEditVC.photoEdit = self.photoEdit;
    } else {
        lfPhotoEditVC.editImage = self.imageView.image;
    }
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:lfPhotoEditVC animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LFPhotoEditingControllerDelegate
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
    if (photoEdit) {
        self.imageView.image = photoEdit.editPreviewImage;
    } else {
        self.imageView.image = self.image;
    }
    self.photoEdit = photoEdit;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
