//
//  PhotoViewController.m
//  LFMediaEditingDEMO
//
//  Created by LamTsanFeng on 2017/6/5.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImage+LF_Format.h"
#import "LFMEGIFImageSerialization.h"

#import "LFPhotoEditingController.h"
#import "UIImage+LFMECommon.h"

@interface PhotoViewController () <LFPhotoEditingControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray<NSNumber *> *durations;
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
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"4.gif" ofType:nil];
//    NSData *imgData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:nil];
//    UIImage *image = [UIImage LF_imageWithImageData:imgData];
    /**
     真实播放GIF
     */
//    self.durations = LFME_UIImageGIFDurationsFromData(imgData, nil);
    /** 非拍照图片 */
//    UIImage *image = [UIImage imageNamed:@"2.png"];
    /** 长图 */
//    UIImage *image = [UIImage imageNamed:@"longImage.jpg"];
    /** 必须确保图片方向是正确的，当然有很多方法更正图片的方向，这里只是举例，请酌情参考。 */
    if (image.images.count) {
        self.image = image;
    } else {
        /** 普通图片更正方向 */
        self.image = [image LFME_fixOrientation];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:self.image];
    [self.view addSubview:imageView];
    [imageView startAnimating];
    
    _imageView = imageView;
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(photoEditing)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(photoadd)];
    
    self.navigationItem.rightBarButtonItems = @[editItem, fixedSpace, addItem];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    if (self.view.safeAreaInsets.bottom > 0) {    
        CGFloat top = self.view.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height;
        self.imageView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y+top, self.view.bounds.size.width, self.view.bounds.size.height-top-self.view.safeAreaInsets.bottom);
    }
}

- (void)photoadd
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//指定数据来源是相册
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//选取图片之后执行的方法

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSLog(@"%@",info);//是个字典
    
    //通过字典的key值来找到图片
    
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];//选取的是原始图片。还有其他的样式；如编辑的图片：UIImagePickerControllerEditedImage
    
    //并且赋值给声明好的imageView
    
    self.imageView.image = self.image;
    
    //最后模态返回 最初的 控制器
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
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
//                                     LFPhotoEditCropAspectRatioAttributeName:@(LFPhotoEditOperationSubTypeCropAspectRatio1x1),
//                                     LFPhotoEditCropCanRotateAttributeName:@(NO),
//                                     LFPhotoEditCropCanAspectRatioAttributeName:@(NO),
//                                     };
    lfPhotoEditVC.operationAttrs = @{
                                     LFPhotoEditCropCanRotateAttributeName: @(NO),
                                     LFPhotoEditCropCanAspectRatioAttributeName:@(YES)
                                     };
    
    lfPhotoEditVC.delegate = self;
    if (self.photoEdit) {
        lfPhotoEditVC.photoEdit = self.photoEdit;
    } else {
        [lfPhotoEditVC setEditImage:self.image durations:self.durations];
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
