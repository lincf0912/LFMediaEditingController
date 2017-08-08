//
//  LFVideoEditingController.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFVideoEditingController.h"
#import "LFMediaEditingHeader.h"
#import "UIView+LFMEFrame.h"
#import "LFMediaEditingType.h"

#import "LFVideoEditingView.h"
#import "LFEditToolbar.h"
#import "LFStickerBar.h"
#import "LFTextBar.h"
#import "LFVideoClipToolbar.h"

@interface LFVideoEditingController () <LFEditToolbarDelegate, LFStickerBarDelegate, LFTextBarDelegate, LFVideoClipToolbarDelegate, LFPhotoEditDelegate>
{
    /** 编辑模式 */
    LFVideoEditingView *_EditingView;
    
    UIView *_edit_naviBar;
    /** 底部栏菜单 */
    LFEditToolbar *_edit_toolBar;
    
    /** 贴图菜单 */
    LFStickerBar *_edit_sticker_toolBar;
    /** 剪切菜单 */
    LFVideoClipToolbar *_edit_clipping_toolBar;
    
    /** 单击手势 */
    UITapGestureRecognizer *singleTapRecognizer;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;
@end

@implementation LFVideoEditingController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationType = LFVideoEditOperationType_All;
        _minClippingDuration = 1.f;
    }
    return self;
}

- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
{
    _asset = [AVURLAsset assetWithURL:url];
    _placeholderImage = image;
    [self setVideoAsset:_asset placeholderImage:image];
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    _asset = asset;
    _placeholderImage = image;
    [_EditingView setVideoAsset:asset placeholderImage:image];
}

- (void)setMinClippingDuration:(double)minClippingDuration
{
    if (minClippingDuration > 0.999) {
        _minClippingDuration = minClippingDuration;
        _EditingView.minClippingDuration = minClippingDuration;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configEditingView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图
- (void)configEditingView
{
    _EditingView = [[LFVideoEditingView alloc] initWithFrame:self.view.bounds];
    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.editDelegate = self;
    _EditingView.minClippingDuration = self.minClippingDuration;
//    _EditingView.clippingDelegate = self;
    if (_videoEdit) {
        _EditingView.photoEditData = _videoEdit.editData;
        [self setVideoAsset:_videoEdit.editAsset placeholderImage:_videoEdit.editPreviewImage];
    } else {
        [self setVideoAsset:_asset placeholderImage:_placeholderImage];
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
    CGFloat buttonHeight = topbarHeight - margin*2;
    
    _edit_naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topbarHeight)];
    _edit_naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _edit_naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [self.cancelButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 2;
    UIButton *_edit_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, editCancelWidth, buttonHeight)];
    _edit_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    _edit_cancelButton.titleLabel.font = font;
    [_edit_cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat editOkWidth = [self.oKButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 5;
    
    UIButton *_edit_finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - (editOkWidth + margin), margin, editOkWidth, buttonHeight)];
    _edit_finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_finishButton setTitle:self.oKButtonTitle forState:UIControlStateNormal];
    _edit_finishButton.titleLabel.font = font;
    [_edit_finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_edit_naviBar addSubview:_edit_finishButton];
    [_edit_naviBar addSubview:_edit_cancelButton];
    
    [self.view addSubview:_edit_naviBar];
}

- (void)configBottomToolBar
{
    LFEditToolbarType toolbarType = 0;
    if (self.operationType&LFVideoEditOperationType_draw) {
        toolbarType |= LFEditToolbarType_draw;
    }
    if (self.operationType&LFVideoEditOperationType_sticker) {
        toolbarType |= LFEditToolbarType_sticker;
    }
    if (self.operationType&LFVideoEditOperationType_text) {
        toolbarType |= LFEditToolbarType_text;
    }
    if (self.operationType&LFVideoEditOperationType_clip) {
        toolbarType |= LFEditToolbarType_crop;
    }
    
    _edit_toolBar = [[LFEditToolbar alloc] initWithType:(toolbarType == 0 ? (LFEditToolbarType_draw|LFEditToolbarType_sticker|LFEditToolbarType_text|LFEditToolbarType_crop) : toolbarType) mediaType:LFEditToolbarMediaType_video];
    _edit_toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _edit_toolBar.delegate = self;
    [_edit_toolBar setDrawSliderColorAtIndex:1]; /** 红色 */
    /** 绘画颜色一致 */
    [_EditingView setDrawColor:[_edit_toolBar drawSliderCurrentColor]];
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
    if ([self.delegate respondsToSelector:@selector(lf_VideoEditingController:didCancelPhotoEdit:)]) {
        [self.delegate lf_VideoEditingController:self didCancelPhotoEdit:self.videoEdit];
    }
}

- (void)finishButtonClick
{
    [self showProgressHUD];
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /** 处理编辑图片 */
        __block LFVideoEdit *videoEdit = nil;
        NSDictionary *data = [_EditingView photoEditData];
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_EditingView exportAsynchronouslyWithTrimVideo:^(NSURL *trimURL, NSError *error) {
                    videoEdit = [[LFVideoEdit alloc] initWithEditAsset:weakSelf.asset editFinalURL:trimURL data:data];
                    if (error) {
                        [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(lf_VideoEditingController:didFinishPhotoEdit:)]) {
                        [weakSelf.delegate lf_VideoEditingController:weakSelf didFinishPhotoEdit:videoEdit];
                    }
                    [weakSelf hideProgressHUD];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(lf_VideoEditingController:didFinishPhotoEdit:)]) {
                    [weakSelf.delegate lf_VideoEditingController:weakSelf didFinishPhotoEdit:videoEdit];
                }
                [weakSelf hideProgressHUD];
            });
        }
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


#pragma mark - LFVideoClipToolbarDelegate
/** 取消 */
- (void)lf_videoClipToolbarDidCancel:(LFVideoClipToolbar *)clipToolbar
{
    [_EditingView cancelClipping:YES];
    [self changeClipMenu:NO];
}
/** 完成 */
- (void)lf_videoClipToolbarDidFinish:(LFVideoClipToolbar *)clipToolbar
{
    [_EditingView setIsClipping:NO animated:YES];
    [self changeClipMenu:NO];
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
            _edit_toolBar.alpha = 0.f;
        } completion:^(BOOL finished) {
            _edit_toolBar.hidden = YES;
        }];
        singleTapRecognizer.enabled = NO;
        [self singlePressed];
    } else {
        if (_edit_clipping_toolBar.superview == nil) return;
        
        /** 开启编辑 */
        [_EditingView photoEditEnable:YES];
        
        singleTapRecognizer.enabled = YES;
        _edit_toolBar.hidden = NO;
        [UIView animateWithDuration:.25f animations:^{
            self.edit_clipping_toolBar.alpha = 0.f;
            _edit_toolBar.alpha = 1.f;
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
    LFTextBar *textBar = [[LFTextBar alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, self.view.height) layout:^(LFTextBar *textBar) {
        textBar.oKButtonTitleColorNormal = self.oKButtonTitleColorNormal;
        textBar.cancelButtonTitleColorNormal = self.cancelButtonTitleColorNormal;
        textBar.oKButtonTitle = self.oKButtonTitle;
        textBar.cancelButtonTitle = self.cancelButtonTitle;        
    }];
    textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textBar.showText = text;
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

#pragma mark - 剪切底部栏（懒加载）
- (UIView *)edit_clipping_toolBar
{
    if (_edit_clipping_toolBar == nil) {
        _edit_clipping_toolBar = [[LFVideoClipToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        _edit_clipping_toolBar.delegate = self;
    }
    return _edit_clipping_toolBar;
}
@end
