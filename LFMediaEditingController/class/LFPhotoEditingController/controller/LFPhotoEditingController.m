//
//  LFPhotoEditingController.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFPhotoEditingController.h"
#import "LFPhotoEditingHeader.h"
#import "UIView+LFMEFrame.h"
#import "LFPhotoEditingType.h"

#import "LFEditingView.h"
#import "LFEditToolbar.h"
#import "LFStickerBar.h"
#import "LFTextBar.h"
#import "LFClipToolbar.h"

#import "UIDevice+LFMEOrientation.h"

#define kSplashMenu_Button_Tag1 95
#define kSplashMenu_Button_Tag2 96



@interface LFPhotoEditingController () <LFEditToolbarDelegate, LFStickerBarDelegate, LFClipToolbarDelegate, LFTextBarDelegate, LFPhotoEditDelegate, LFEditingViewDelegate>
{
    /** 编辑模式 */
    LFEditingView *_EditingView;
    
    UIView *_edit_naviBar;
    /** 底部栏菜单 */
    LFEditToolbar *_edit_toolBar;
    /** 剪切菜单 */
    LFClipToolbar *_edit_clipping_toolBar;
    
    /** 贴图菜单 */
    LFStickerBar *_edit_sticker_toolBar;
    
    /** 单击手势 */
    UITapGestureRecognizer *singleTapRecognizer;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;

@end

@implementation LFPhotoEditingController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
        _oKButtonTitleColorNormal = [UIColor colorWithRed:(26/255.0) green:(173/255.0) blue:(25/255.0) alpha:1.0];
        _cancelButtonTitleColorNormal = [UIColor colorWithWhite:0.8f alpha:1.f];
        _isHiddenStatusBar = YES;
        _processHintStr = @"正在处理...";
    }
    return self;
}

- (void)setEditImage:(UIImage *)editImage
{
    _editImage = editImage;
    /** GIF图片仅支持编辑第一帧 */
    if (editImage.images.count) {
        editImage = editImage.images.firstObject;
    }
    _EditingView.image = editImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configScrollView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc{
    [self hideProgressHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图
- (void)configScrollView
{
    _EditingView = [[LFEditingView alloc] initWithFrame:self.view.bounds];
    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.editDelegate = self;
    _EditingView.clippingDelegate = self;
    if (_photoEdit) {
        [self setEditImage:_photoEdit.editImage];
        _EditingView.photoEditData = _photoEdit.editData;
    } else {
        [self setEditImage:_editImage];
    }
    
    /** 单击的 Recognizer */
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePressed)];
    /** 点击的次数 */
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    /** 给view添加一个手势监测 */
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    [self.view addSubview:_EditingView];
}

- (void)configCustomNaviBar
{
    CGFloat margin = 10, topbarHeight = 64;
    CGFloat size = topbarHeight - margin*2;
    
    _edit_naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topbarHeight)];
    _edit_naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _edit_naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    UIButton *_edit_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, size, size)];
    _edit_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _edit_cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_edit_cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *_edit_finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - (size + margin), margin, size, size)];
    _edit_finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_finishButton setTitle:@"完成" forState:UIControlStateNormal];
    _edit_finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_edit_finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_edit_naviBar addSubview:_edit_finishButton];
    [_edit_naviBar addSubview:_edit_cancelButton];
    
    [self.view addSubview:_edit_naviBar];
}

- (void)configBottomToolBar
{
    _edit_toolBar = [[LFEditToolbar alloc] init];
    _edit_toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _edit_toolBar.delegate = self;
    UIColor *defaultColor = kSliderColors[1];
    [_edit_toolBar setDrawSliderColor:defaultColor]; /** 红色 */
    /** 绘画颜色一致 */
    [_EditingView setDrawColor:defaultColor];
    [self.view addSubview:_edit_toolBar];
}

#pragma mark - 顶部栏(action)
- (void)singlePressed
{
    _isHideNaviBar = !_isHideNaviBar;
    [self changedBarState];
}
- (void)cancelButtonClick
{
    if ([self.delegate respondsToSelector:@selector(lf_PhotoEditingController:didCancelPhotoEdit:)]) {
        [self.delegate lf_PhotoEditingController:self didCancelPhotoEdit:self.photoEdit];
    }
}

- (void)finishButtonClick
{
    [self showProgressHUD];
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /** 处理编辑图片 */
        LFPhotoEdit *photoEdit = nil;
        NSDictionary *data = [_EditingView photoEditData];
        if (data) {
            UIImage *image = [_EditingView createEditImage];
            photoEdit = [[LFPhotoEdit alloc] initWithEditImage:self.editImage previewImage:image data:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(lf_PhotoEditingController:didFinishPhotoEdit:)]) {
                [self.delegate lf_PhotoEditingController:self didFinishPhotoEdit:photoEdit];
            }
            [self hideProgressHUD];
        });
    });
}

#pragma mark - LFEditToolbarDelegate 底部栏(action)

/** 一级菜单点击事件 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar mainDidSelectAtIndex:(NSUInteger)index
{
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    switch (index) {
        case 0:
        {
            /** 关闭涂抹 */
            _EditingView.splashEnable = NO;
            /** 打开绘画 */
            _EditingView.drawEnable = !_EditingView.drawEnable;
        }
            break;
        case 1:
        {
            [self singlePressed];
            [self changeStickerMenu:YES];
        }
            break;
        case 2:
        {
            [self showTextBarController:nil];
        }
            break;
        case 3:
        {
            /** 关闭绘画 */
            _EditingView.drawEnable = NO;
            /** 打开涂抹 */
            _EditingView.splashEnable = !_EditingView.splashEnable;
        }
            break;
        case 4:
        {
            [_EditingView setIsClipping:YES animated:YES];
            [self changeClipMenu:YES];
            _edit_clipping_toolBar.enableReset = _EditingView.canReset;
        }
            break;
        default:
            break;
    }
}
/** 二级菜单点击事件-撤销 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar subDidRevokeAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
        {
            [_EditingView drawUndo];
        }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
        {
            [_EditingView splashUndo];
        }
            break;
        case 4:
            break;
        default:
            break;
    }
}
/** 二级菜单点击事件-按钮 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar subDidSelectAtIndex:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
        {
            _EditingView.splashState = indexPath.row == 1;
        }
            break;
        case 4:
            break;
        default:
            break;
    }
}
/** 撤销允许权限获取 */
- (BOOL)lf_editToolbar:(LFEditToolbar *)editToolbar canRevokeAtIndex:(NSUInteger)index
{
    BOOL canUndo = NO;
    switch (index) {
        case 0:
        {
            canUndo = [_EditingView drawCanUndo];
        }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
        {
            canUndo = [_EditingView splashCanUndo];
        }
            break;
        case 4:
            break;
        default:
            break;
    }
    
    return canUndo;
}
/** 二级菜单滑动事件-绘画 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar drawColorDidChange:(UIColor *)color
{
    [_EditingView setDrawColor:color];
}

#pragma mark - 剪切底部栏（懒加载）
- (UIView *)edit_clipping_toolBar
{
    if (_edit_clipping_toolBar == nil) {
        _edit_clipping_toolBar = [[LFClipToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        _edit_clipping_toolBar.delegate = self;
    }
    return _edit_clipping_toolBar;
}

#pragma mark - LFClipToolbarDelegate
/** 取消 */
- (void)lf_clipToolbarDidCancel:(LFClipToolbar *)clipToolbar
{
    [_EditingView cancelClipping:YES];
    [self changeClipMenu:NO];
}
/** 完成 */
- (void)lf_clipToolbarDidFinish:(LFClipToolbar *)clipToolbar
{
    [_EditingView setIsClipping:NO animated:YES];
    [self changeClipMenu:NO];
}
/** 重置 */
- (void)lf_clipToolbarDidReset:(LFClipToolbar *)clipToolbar
{
    [_EditingView reset];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
}
/** 旋转 */
- (void)lf_clipToolbarDidRotate:(LFClipToolbar *)clipToolbar
{
    [_EditingView rotate];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
}

#pragma mark - 贴图菜单（懒加载）
- (LFStickerBar *)edit_sticker_toolBar
{
    if (_edit_sticker_toolBar == nil) {
        CGFloat w=self.view.width, h=175.f;
        _edit_sticker_toolBar = [[LFStickerBar alloc] initWithFrame:CGRectMake(0, self.view.height, w, h)];
        _edit_sticker_toolBar.delegate = self;
    }
    return _edit_sticker_toolBar;
}

#pragma mark - LFStickerBarDelegate
- (void)lf_stickerBar:(LFStickerBar *)lf_stickerBar didSelectImage:(UIImage *)image
{
    if (image) {
        [_EditingView createStickerImage:image];
    }
    [self singlePressed];
}

#pragma mark - LFTextBarDelegate
/** 完成回调 */
- (void)lf_textBarController:(LFTextBar *)textBar didFinishText:(LFText *)text
{
    if (text) {
        /** 判断是否更改文字 */
        if (textBar.showText) {
            [_EditingView changeSelectStickerText:text];
        } else {
            [_EditingView createStickerText:text];
        }
    } else {
        if (textBar.showText) { /** 文本被清除，删除贴图 */
            [_EditingView removeSelectStickerView];
        }
    }
    [self lf_textBarControllerDidCancel:textBar];
}
/** 取消回调 */
- (void)lf_textBarControllerDidCancel:(LFTextBar *)textBar
{
    /** 显示顶部栏 */
    _isHideNaviBar = NO;
    [self changedBarState];
    /** 更改文字情况才重新激活贴图 */
    if (textBar.showText) {
        [_EditingView activeSelectStickerView];
    }
    [textBar resignFirstResponder];
    
    [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        textBar.y = self.view.height;
    } completion:^(BOOL finished) {
        [textBar removeFromSuperview];
    }];
}

#pragma mark - LFPhotoEditDelegate
#pragma mark - LFPhotoEditDrawDelegate
/** 开始绘画 */
- (void)lf_photoEditDrawBegan
{
    _isHideNaviBar = YES;
    [self changedBarState];
}
/** 结束绘画 */
- (void)lf_photoEditDrawEnded
{
    /** 撤销生效 */
    if (_EditingView.drawCanUndo) [_edit_toolBar setRevokeAtIndex:LFPhotoEditingType_draw];
    
    _isHideNaviBar = NO;
    [self changedBarState];
}

#pragma mark - LFPhotoEditStickerDelegate
/** 点击贴图 isActive=YES 选中的情况下点击 */
- (void)lf_photoEditStickerDidSelectViewIsActive:(BOOL)isActive
{
    _isHideNaviBar = NO;
    [self changedBarState];
    if (isActive) { /** 选中的情况下点击 */
        LFText *text = [_EditingView getSelectStickerText];
        if (text) {
            [self showTextBarController:text];
        }
    }
}

#pragma mark - LFPhotoEditSplashDelegate
/** 开始模糊 */
- (void)lf_photoEditSplashBegan
{
    _isHideNaviBar = YES;
    [self changedBarState];
}
/** 结束模糊 */
- (void)lf_photoEditSplashEnded
{
    /** 撤销生效 */
    if (_EditingView.splashCanUndo) [_edit_toolBar setRevokeAtIndex:LFPhotoEditingType_splash];
    
    _isHideNaviBar = NO;
    [self changedBarState];
}

#pragma mark - LFEditingViewDelegate
/** 剪裁发生变化后 */
- (void)lf_EditingViewDidEndZooming:(LFEditingView *)EditingView
{
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
}
/** 剪裁目标移动后 */
- (void)lf_EditingViewEndDecelerating:(LFEditingView *)EditingView
{
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
}

#pragma mark - private
- (void)changedBarState
{
    /** 隐藏贴图菜单 */
    [self changeStickerMenu:NO];
    
    [UIView animateWithDuration:.25f animations:^{
        CGFloat alpha = _isHideNaviBar ? 0.f : 1.f;
        _edit_naviBar.alpha = alpha;
        _edit_toolBar.alpha = alpha;
    }];
}

- (void)changeClipMenu:(BOOL)isChanged
{
    if (isChanged) {
        /** 关闭所有编辑 */
        [_EditingView photoEditEnable:NO];
        /** 切换菜单 */
        [self.view addSubview:self.edit_clipping_toolBar];
        [UIView animateWithDuration:0.25f animations:^{
            self.edit_clipping_toolBar.alpha = 1.f;
        }];
        singleTapRecognizer.enabled = NO;
        [self singlePressed];
    } else {
        if (_edit_clipping_toolBar.superview == nil) return;

        /** 开启编辑 */
        [_EditingView photoEditEnable:YES];
        
        singleTapRecognizer.enabled = YES;
        [UIView animateWithDuration:.25f animations:^{
            self.edit_clipping_toolBar.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.edit_clipping_toolBar removeFromSuperview];
        }];
        
        [self singlePressed];
    }
}

- (void)changeStickerMenu:(BOOL)isChanged
{
    if (isChanged) {
        [self.view addSubview:self.edit_sticker_toolBar];
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.height-frame.size.height;
        [UIView animateWithDuration:.25f animations:^{
            self.edit_sticker_toolBar.frame = frame;
        }];
    } else {
        if (_edit_sticker_toolBar.superview == nil) return;
        
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.height;
        [UIView animateWithDuration:.25f animations:^{
            self.edit_sticker_toolBar.frame = frame;
        } completion:^(BOOL finished) {
            [_edit_sticker_toolBar removeFromSuperview];
            _edit_sticker_toolBar = nil;
        }];
    }
}

- (void)showTextBarController:(LFText *)text
{
    LFTextBar *textBar = [[LFTextBar alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, self.view.height)];
    textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textBar.showText = text;
    textBar.oKButtonTitleColorNormal = self.oKButtonTitleColorNormal;
    textBar.delegate = self;

    [self.view addSubview:textBar];
    
    [textBar becomeFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        textBar.y = 0;
    } completion:^(BOOL finished) {
        /** 隐藏顶部栏 */
        _isHideNaviBar = YES;
        [self changedBarState];
    }];
}

#pragma mark - 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return self.isHiddenStatusBar;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - private
- (void)showProgressHUDText:(NSString *)text isTop:(BOOL)isTop
{
    [self hideProgressHUD];
    
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        _progressHUD.frame = [UIScreen mainScreen].bounds;
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 120) / 2, ([[UIScreen mainScreen] bounds].size.height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.frame = CGRectMake(0,40, 120, 50);
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    
    _HUDLabel.text = text ? text : self.processHintStr;
    
    [_HUDIndicatorView startAnimating];
    UIView *view = isTop ? [[UIApplication sharedApplication] keyWindow] : self.view;
    [view addSubview:_progressHUD];
}

- (void)showProgressHUDText:(NSString *)text
{
    [self showProgressHUDText:text isTop:NO];
}

- (void)showProgressHUD {
    
    [self showProgressHUDText:nil];
    
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}


@end
