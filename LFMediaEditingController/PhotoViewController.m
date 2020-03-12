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

// 测试UIModalPresentationPageSheet模式
//#define PresentationPageSheet

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
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"1.jpg" ofType:nil];
    
    /** gif */
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"4.gif" ofType:nil];
    /**
     真实播放GIF
     */
//    NSData *imgData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:nil];
//    self.durations = LFME_UIImageGIFDurationsFromData(imgData, nil);
    /** 非拍照图片 */
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"2.png" ofType:nil];
    /** 长图 */
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"longImage.jpg" ofType:nil];
    /** 使用UIImage imageNamed加载的UIImage不能序列化 */
    UIImage *image = [UIImage LF_imageWithImagePath:imagePath];
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
    self.photoEdit = nil;
    //最后模态返回 最初的 控制器
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)photoEditing
{
//    NSArray *stickerGifs = @[[NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/677/w400h277/20200219/4639-iprtayz5721379.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/40/w420h420/20200214/b778-ipmxpvz6387339.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/362/w244h118/20200214/d095-ipmxpvz6380936.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/552/w315h237/20200214/75d2-ipmxpvz6380604.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/538/w350h188/20200214/49ef-ipmxpvz6378358.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/18/w536h282/20200213/256b-ipmxpvz2333375.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/755/w280h475/20200213/ae28-ipmxpvz2324934.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/704/w351h353/20200213/34b7-ipmxpvz2320937.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/474/w308h166/20200213/3554-ipmxpvz2313851.gif"], [NSURL URLWithString:@"https://fail.gif"]];
//
//    NSURL *appendFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1.jpg" ofType:nil]];
//    NSURL *failFile = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"test"]];
    
    LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
//    lfPhotoEditVC.operationType = LFPhotoEditOperationType_draw | LFPhotoEditOperationType_splash;
//    lfPhotoEditVC.defaultOperationType = LFPhotoEditOperationType_crop; // 默认剪裁
//    lfPhotoEditVC.operationAttrs = @{
//                                     LFPhotoEditDrawColorAttributeName:@(LFPhotoEditOperationSubTypeDrawVioletRedColor), // 绘画紫罗兰红色
//                                     LFPhotoEditDrawBrushAttributeName:@(LFPhotoEditOperationSubTypeDrawStampFruitBrush), // 绘画笔刷
//                                     LFPhotoEditStickerContentsAttributeName:@[
//                                             [LFStickerContent stickerContentWithTitle:@"默认" contents:@[
//                                                 appendFile,
//                                                 failFile,
//                                                 LFStickerContentDefaultSticker]],
//                                             [LFStickerContent stickerContentWithTitle:@"相册" contents:@[
//                                                 LFStickerContentAllAlbum
//                                             ]],
//                                             [LFStickerContent stickerContentWithTitle:@"GIF" contents:stickerGifs]
//                                                                                ], // 贴图资源
//                                     LFPhotoEditTextColorAttributeName:@(LFPhotoEditOperationSubTypeTextAzureColor), // 字体天蓝色
//                                     LFPhotoEditSplashAttributeName:@(LFPhotoEditOperationSubTypeSplashPaintbrush), //涂抹效果
//                                     LFPhotoEditFilterAttributeName:@(LFPhotoEditOperationSubTypeProcessFilter), //滤镜效果
//                                     LFPhotoEditCropAspectRatioAttributeName:@(LFPhotoEditOperationSubTypeCropAspectRatio1x1), //剪裁尺寸
//                                     LFPhotoEditCropCanRotateAttributeName:@(NO), //不允许剪切旋转
//                                     LFPhotoEditCropCanAspectRatioAttributeName:@(NO), //不允许剪切比例调整
//                                     };
    
    lfPhotoEditVC.delegate = self;
    LFPhotoEdit *photoEdit = self.photoEdit;
    if (photoEdit) {
        lfPhotoEditVC.photoEdit = photoEdit;
    } else {
        [lfPhotoEditVC setEditImage:self.image durations:self.durations];
    }
    
#ifdef PresentationPageSheet
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lfPhotoEditVC];
    [navi setNavigationBarHidden:YES];
    [self presentViewController:navi animated:YES completion:nil];
#else
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:lfPhotoEditVC animated:NO];
#endif
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LFPhotoEditingControllerDelegate
- (void)lf_PhotoEditingControllerDidCancel:(LFPhotoEditingController *)photoEditingVC
{
#ifdef PresentationPageSheet
    [self dismissViewControllerAnimated:YES completion:nil];
#else
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
#endif
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit
{
#ifdef PresentationPageSheet
    [self dismissViewControllerAnimated:YES completion:nil];
#else
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
#endif
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
