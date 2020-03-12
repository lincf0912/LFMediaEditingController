//
//  LFPhotoEditingController.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFPhotoEditingController.h"
#import "LFMediaEditingHeader.h"
#import "UIView+LFMEFrame.h"
#import "UIImage+LFMECommon.h"
#import "LFMediaEditingType.h"
#import "LFMECancelBlock.h"

#import "LFEditingView.h"
#import "LFEditToolbar.h"
#import "LFStickerBar.h"
#import "LFTextBar.h"
#import "LFClipToolbar.h"
#import "JRFilterBar.h"
#import "LFSafeAreaMaskView.h"

#import "FilterSuiteUtils.h"
#import "LFImageCoder.h"

/************************ Attributes ************************/
/** 绘画颜色 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditDrawColorAttributeName = @"LFPhotoEditDrawColorAttributeName";
/** 绘画笔刷 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditDrawBrushAttributeName = @"LFPhotoEditDrawBrushAttributeName";
/** 自定义贴图资源路径 NSString containing string path, default nil. sticker resource path. */
LFPhotoEditOperationStringKey const LFPhotoEditStickerAttributeName = @"LFPhotoEditStickerAttributeName";
/** NSArray containing NSArray<LFStickerContent *>, default @[[LFStickerContent stickerContentWithTitle:@"默认" contents:@[LFStickerContentDefaultSticker]]]. */
LFPhotoEditOperationStringKey const LFPhotoEditStickerContentsAttributeName = @"LFPhotoEditStickerContentsAttributeName";
/** 文字颜色 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditTextColorAttributeName = @"LFPhotoEditTextColorAttributeName";
/** 模糊类型 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditSplashAttributeName = @"LFPhotoEditSplashAttributeName";
/** 滤镜类型 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditFilterAttributeName = @"LFPhotoEditFilterAttributeName";
/** 剪切比例 NSNumber containing LFPhotoEditOperationSubType, default 0 */
LFPhotoEditOperationStringKey const LFPhotoEditCropAspectRatioAttributeName = @"LFPhotoEditCropAspectRatioAttributeName";
/** 允许剪切旋转 NSNumber containing LFPhotoEditOperationSubType, default YES */
LFPhotoEditOperationStringKey const LFPhotoEditCropCanRotateAttributeName = @"LFPhotoEditCropCanRotateAttributeName";
/** 允许剪切比例 NSNumber containing LFPhotoEditOperationSubType, default YES */
LFPhotoEditOperationStringKey const LFPhotoEditCropCanAspectRatioAttributeName = @"LFPhotoEditCropCanAspectRatioAttributeName";
/************************ Attributes ************************/

@interface LFPhotoEditingController () <LFEditToolbarDelegate, LFStickerBarDelegate, JRFilterBarDelegate, JRFilterBarDataSource, LFClipToolbarDelegate, LFEditToolbarDataSource, LFTextBarDelegate, LFPhotoEditDelegate, LFEditingViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    /** 编辑模式 */
    LFEditingView *_EditingView;
    
    UIView *_edit_naviBar;
    /** 底部栏菜单 */
    LFEditToolbar *_edit_toolBar;
    /** 剪切菜单 */
    LFClipToolbar *_edit_clipping_toolBar;
    /** 安全区域涂层 */
    LFSafeAreaMaskView *_edit_clipping_safeAreaMaskView;
    
    /** 贴图菜单 */
    LFStickerBar *_edit_sticker_toolBar;
    
    /** 滤镜菜单 */
    JRFilterBar *_edit_filter_toolBar;
    
    /** 单击手势 */
    UITapGestureRecognizer *singleTapRecognizer;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;
/** 初始化以选择的功能类型，已经初始化过的将被去掉类型，最终类型为0 */
@property (nonatomic, assign) LFPhotoEditOperationType initSelectedOperationType;

@property (nonatomic, copy) lf_me_dispatch_cancelable_block_t delayCancelBlock;

/** 滤镜缩略图 */
@property (nonatomic, strong) UIImage *filterSmallImage;
/**
 GIF每帧的持续时间
 */
@property (nonatomic, strong) NSArray<NSNumber *> *durations;

@property (nonatomic, strong, nullable) NSDictionary *editData;

@property (nonatomic, strong, nullable) id stickerBarCacheResource;

@end

@implementation LFPhotoEditingController

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self) {
        _operationType = LFPhotoEditOperationType_All;
    }
    return self;
}

- (void)setEditImage:(UIImage *)editImage
{
    [self setEditImage:editImage durations:nil];
}

- (void)setEditImage:(UIImage *)editImage durations:(NSArray<NSNumber *> *)durations
{
    _editImage = LFIC_UIImageDecodedCopy(editImage);
    _durations = durations;
    
    if (_editImage.images.count) {
        /** gif不能使用模糊功能 */
        if (_operationType & LFPhotoEditOperationType_splash) {
            _operationType ^= LFPhotoEditOperationType_splash;
        }
    }
}

- (void)setPhotoEdit:(LFPhotoEdit *)photoEdit
{
    [self setEditImage:photoEdit.editImage durations:photoEdit.durations];
    _editData = photoEdit.editData;
}

- (void)setDefaultOperationType:(LFPhotoEditOperationType)defaultOperationType
{
    _defaultOperationType = defaultOperationType;
    _initSelectedOperationType = defaultOperationType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 为了适配iOS13的UIModalPresentationPageSheet模态，它会在viewDidLoad之后对self.view的大小调整，迫不得已暂时只能在viewWillAppear加载视图 */
    if (@available(iOS 13.0, *)) {
        if (isiPhone && self.presentingViewController && self.navigationController.modalPresentationStyle == UIModalPresentationPageSheet) {
            return;
        }
    }
    [self configScrollView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
    [self configDefaultOperation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_EditingView == nil) {
        [self configScrollView];
        [self configCustomNaviBar];
        [self configBottomToolBar];
        [self configDefaultOperation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        _edit_naviBar.height = kCustomTopbarHeight_iOS11;
    } else {
        _edit_naviBar.height = kCustomTopbarHeight;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图
- (void)configScrollView
{
    CGRect editRect = self.view.bounds;
    
    if (@available(iOS 11.0, *)) {
        if (hasSafeArea) {
            editRect.origin.x += self.navigationController.view.safeAreaInsets.left;
            editRect.origin.y += self.navigationController.view.safeAreaInsets.top;
            editRect.size.width -= (self.navigationController.view.safeAreaInsets.left+self.navigationController.view.safeAreaInsets.right);
            editRect.size.height -= (self.navigationController.view.safeAreaInsets.top+self.navigationController.view.safeAreaInsets.bottom);
        }
    }
    
    _EditingView = [[LFEditingView alloc] initWithFrame:editRect];
//    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.editDelegate = self;
    _EditingView.clippingDelegate = self;
    _EditingView.fixedAspectRatio = ![self operationBOOLForKey:LFPhotoEditCropCanAspectRatioAttributeName];
    
    /** 单击的 Recognizer */
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePressed)];
    /** 点击的次数 */
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    singleTapRecognizer.delegate = self;
    /** 给view添加一个手势监测 */
    [self.view addGestureRecognizer:singleTapRecognizer];
    self.view.exclusiveTouch = YES;
    
    [self.view addSubview:_EditingView];
    
    [_EditingView setImage:self.editImage durations:self.durations];
    if (self.editData) {
        // 设置编辑数据
        _EditingView.photoEditData = self.editData;
        // 释放销毁
        self.editData = nil;
    } else {
        /** 设置默认滤镜 */
        if (@available(iOS 9.0, *)) {
            if (self.operationType&LFPhotoEditOperationType_filter) {
                LFPhotoEditOperationSubType subType = [self operationSubTypeForKey:LFPhotoEditFilterAttributeName];
                NSInteger index = 0;
                switch (subType) {
                    case LFPhotoEditOperationSubTypeLinearCurveFilter:
                    case LFPhotoEditOperationSubTypeChromeFilter:
                    case LFPhotoEditOperationSubTypeFadeFilter:
                    case LFPhotoEditOperationSubTypeInstantFilter:
                    case LFPhotoEditOperationSubTypeMonoFilter:
                    case LFPhotoEditOperationSubTypeNoirFilter:
                    case LFPhotoEditOperationSubTypeProcessFilter:
                    case LFPhotoEditOperationSubTypeTonalFilter:
                    case LFPhotoEditOperationSubTypeTransferFilter:
                    case LFPhotoEditOperationSubTypeCurveLinearFilter:
                    case LFPhotoEditOperationSubTypeInvertFilter:
                    case LFPhotoEditOperationSubTypeMonochromeFilter:
                        index = subType % 400 + 1;
                    default:
                        break;
                }
                
                if (index > 0) {
                    [_EditingView changeFilterType:index];
                }
            }
        }
        
        /** 设置默认剪裁比例 */
        if (self.operationType&LFPhotoEditOperationType_crop) {
            LFPhotoEditOperationSubType subType = [self operationSubTypeForKey:LFPhotoEditCropAspectRatioAttributeName];
            NSInteger index = 0;
            switch (subType) {
                case LFPhotoEditOperationSubTypeCropAspectRatioOriginal:
                case LFPhotoEditOperationSubTypeCropAspectRatio1x1:
                case LFPhotoEditOperationSubTypeCropAspectRatio3x2:
                case LFPhotoEditOperationSubTypeCropAspectRatio4x3:
                case LFPhotoEditOperationSubTypeCropAspectRatio5x3:
                case LFPhotoEditOperationSubTypeCropAspectRatio15x9:
                case LFPhotoEditOperationSubTypeCropAspectRatio16x9:
                case LFPhotoEditOperationSubTypeCropAspectRatio16x10:
                    index = subType % 500 + 1;
                    break;
                default:
                    break;
            }
            
            _EditingView.defaultAspectRatioIndex = index;
        }
    }
}

- (void)configCustomNaviBar
{
    CGFloat margin = 8, topbarHeight = 0;
    if (@available(iOS 11.0, *)) {
        topbarHeight = kCustomTopbarHeight_iOS11;
    } else {
        topbarHeight = kCustomTopbarHeight;
    }
    CGFloat naviHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    _edit_naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topbarHeight)];
    _edit_naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _edit_naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight-naviHeight, _edit_naviBar.frame.size.width, naviHeight)];
    naviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_edit_naviBar addSubview:naviBar];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [[NSBundle LFME_localizedStringForKey:@"_LFME_cancelButtonTitle"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *_edit_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, 0, editCancelWidth, naviHeight)];
    _edit_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_cancelButton setTitle:[NSBundle LFME_localizedStringForKey:@"_LFME_cancelButtonTitle"] forState:UIControlStateNormal];
    _edit_cancelButton.titleLabel.font = font;
    [_edit_cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:_edit_cancelButton];
    
    CGFloat editOkWidth = [[NSBundle LFME_localizedStringForKey:@"_LFME_oKButtonTitle"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;

    UIButton *_edit_finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - editOkWidth-margin, 0, editOkWidth, naviHeight)];
    _edit_finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_edit_finishButton setTitle:[NSBundle LFME_localizedStringForKey:@"_LFME_oKButtonTitle"] forState:UIControlStateNormal];
    _edit_finishButton.titleLabel.font = font;
    [_edit_finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_edit_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:_edit_finishButton];
    
    [self.view addSubview:_edit_naviBar];
}

- (void)configBottomToolBar
{
    LFEditToolbarType toolbarType = 0;
    if (self.operationType&LFPhotoEditOperationType_draw) {
        toolbarType |= LFEditToolbarType_draw;
    }
    if (self.operationType&LFPhotoEditOperationType_sticker) {
        toolbarType |= LFEditToolbarType_sticker;
    }
    if (self.operationType&LFPhotoEditOperationType_text) {
        toolbarType |= LFEditToolbarType_text;
    }
    if (self.operationType&LFPhotoEditOperationType_splash) {
        toolbarType |= LFEditToolbarType_splash;
    }
    if (self.operationType&LFPhotoEditOperationType_crop) {
        toolbarType |= LFEditToolbarType_crop;
    }
    if (@available(iOS 9.0, *)) {
        if (self.operationType&LFPhotoEditOperationType_filter) {
            toolbarType |= LFEditToolbarType_filter;
        }
    }
    
    _edit_toolBar = [[LFEditToolbar alloc] initWithType:toolbarType];
    _edit_toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _edit_toolBar.delegate = self;
    
    if (self.operationType&LFPhotoEditOperationType_splash) {
        __weak typeof(_edit_toolBar) weakToolBar = _edit_toolBar;
        /** 加载涂抹相关画笔 */
        if (![LFMosaicBrush mosaicBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:LFSplashStateType_Mosaic];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [LFMosaicBrush loadBrushImage:self.editImage scale:15.0 canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:LFSplashStateType_Mosaic];
            }];
        }
        if (![LFBlurryBrush blurryBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:LFSplashStateType_Blurry];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [LFBlurryBrush loadBrushImage:self.editImage radius:5.0 canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:LFSplashStateType_Blurry];
            }];
        }
        if (![LFSmearBrush smearBrushCache]) {
            [_edit_toolBar setSplashWait:YES index:LFSplashStateType_Smear];
            CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editImage.size, _EditingView.bounds).size;
            [LFSmearBrush loadBrushImage:self.editImage canvasSize:canvasSize useCache:YES complete:^(BOOL success) {
                [weakToolBar setSplashWait:NO index:LFSplashStateType_Smear];
            }];
        }
    }
    
    NSInteger index = 2; /** 红色 */
    
    /** 设置默认绘画颜色 */
    if (self.operationType&LFPhotoEditOperationType_draw) {
        LFPhotoEditOperationSubType subType = [self operationSubTypeForKey:LFPhotoEditDrawColorAttributeName];
        switch (subType) {
            case LFPhotoEditOperationSubTypeDrawWhiteColor:
            case LFPhotoEditOperationSubTypeDrawBlackColor:
            case LFPhotoEditOperationSubTypeDrawRedColor:
            case LFPhotoEditOperationSubTypeDrawLightYellowColor:
            case LFPhotoEditOperationSubTypeDrawYellowColor:
            case LFPhotoEditOperationSubTypeDrawLightGreenColor:
            case LFPhotoEditOperationSubTypeDrawGreenColor:
            case LFPhotoEditOperationSubTypeDrawAzureColor:
            case LFPhotoEditOperationSubTypeDrawRoyalBlueColor:
            case LFPhotoEditOperationSubTypeDrawBlueColor:
            case LFPhotoEditOperationSubTypeDrawPurpleColor:
            case LFPhotoEditOperationSubTypeDrawLightPinkColor:
            case LFPhotoEditOperationSubTypeDrawVioletRedColor:
            case LFPhotoEditOperationSubTypeDrawPinkColor:
                index = subType - 1;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawSliderColorAtIndex:index];
        
        subType = [self operationSubTypeForKey:LFPhotoEditDrawBrushAttributeName];

        EditToolbarBrushType brushType = 0;
        EditToolbarStampBrushType stampBrushType = 0;
        switch (subType) {
            case LFPhotoEditOperationSubTypeDrawPaintBrush:
            case LFPhotoEditOperationSubTypeDrawHighlightBrush:
            case LFPhotoEditOperationSubTypeDrawChalkBrush:
            case LFPhotoEditOperationSubTypeDrawFluorescentBrush:
                brushType = subType % 50;
                break;
            case LFPhotoEditOperationSubTypeDrawStampAnimalBrush:
                brushType = EditToolbarBrushTypeStamp;
                stampBrushType = EditToolbarStampBrushTypeAnimal;
                break;
            case LFPhotoEditOperationSubTypeDrawStampFruitBrush:
                brushType = EditToolbarBrushTypeStamp;
                stampBrushType = EditToolbarStampBrushTypeFruit;
                break;
            case LFPhotoEditOperationSubTypeDrawStampHeartBrush:
                brushType = EditToolbarBrushTypeStamp;
                stampBrushType = EditToolbarStampBrushTypeHeart;
                break;
            default:
                break;
        }
        [_edit_toolBar setDrawBrushAtIndex:brushType subIndex:stampBrushType];
    }
    
    /** 设置默认模糊 */
    if (self.operationType&LFPhotoEditOperationType_splash) {
        /** 重置 */
        index = 0;
        LFPhotoEditOperationSubType subType = [self operationSubTypeForKey:LFPhotoEditSplashAttributeName];
        switch (subType) {
            case LFPhotoEditOperationSubTypeSplashMosaic:
            case LFPhotoEditOperationSubTypeSplashBlurry:
            case LFPhotoEditOperationSubTypeSplashPaintbrush:
                index = subType % 300;
                break;
            default:
                break;
        }
        [_edit_toolBar setSplashIndex:index];
    }
    
    
    [self.view addSubview:_edit_toolBar];
}

- (void)configDefaultOperation
{
    if (self.initSelectedOperationType > 0) {
        __weak typeof(self) weakSelf = self;
        BOOL (^containOperation)(LFPhotoEditOperationType type) = ^(LFPhotoEditOperationType type){
            if (weakSelf.operationType&type && weakSelf.initSelectedOperationType&type) {
                weakSelf.initSelectedOperationType ^= type;
                return YES;
            }
            return NO;
        };
        
        if (containOperation(LFPhotoEditOperationType_crop)) {
//            [_EditingView setClipping:YES animated:NO];
//            [self changeClipMenu:YES animated:NO];
            [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_crop];
        } else {
            if (containOperation(LFPhotoEditOperationType_draw)) {
                [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_draw];
            } else if (containOperation(LFPhotoEditOperationType_sticker)) {
                [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_sticker];
            } else if (containOperation(LFPhotoEditOperationType_text)) {
                [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_text];
            } else if (containOperation(LFPhotoEditOperationType_splash)) {
                [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_splash];
            } else {
                if (@available(iOS 9.0, *)) {
                    if (containOperation(LFPhotoEditOperationType_filter)) {
                        [_edit_toolBar selectMainMenuIndex:LFEditToolbarType_filter];
                    }
                }
            }
            self.initSelectedOperationType = 0;
        }
    }
}

#pragma mark - 顶部栏(action)
- (void)singlePressed
{
    [self singlePressedWithAnimated:YES];
}
- (void)singlePressedWithAnimated:(BOOL)animated
{
    if (!(_EditingView.isDrawing || _EditingView.isSplashing)) {
        _isHideNaviBar = !_isHideNaviBar;
        [self changedBarStateWithAnimated:animated];
    }
}
- (void)cancelButtonClick
{
    if ([self.delegate respondsToSelector:@selector(lf_PhotoEditingControllerDidCancel:)]) {
        [self.delegate lf_PhotoEditingControllerDidCancel:self];
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ([self.delegate respondsToSelector:@selector(lf_PhotoEditingController:didCancelPhotoEdit:)]) {
        [self.delegate lf_PhotoEditingController:self didCancelPhotoEdit:nil];
    }
    #pragma clang diagnostic pop
}

- (void)finishButtonClick
{
    [self showProgressHUD];
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    /** 处理编辑图片 */
    __block LFPhotoEdit *photoEdit = nil;
    NSDictionary *data = [_EditingView photoEditData];
    __weak typeof(self) weakSelf = self;
    
    void (^finishImage)(UIImage *) = ^(UIImage *image){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (data) {
                photoEdit = [[LFPhotoEdit alloc] initWithEditImage:weakSelf.editImage previewImage:LFIC_UIImageDecodedCopy(image) durations:weakSelf.durations data:data];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(lf_PhotoEditingController:didFinishPhotoEdit:)]) {
                    [weakSelf.delegate lf_PhotoEditingController:self didFinishPhotoEdit:photoEdit];
                }
                [weakSelf hideProgressHUD];
            });
        });
    };
    
    if (data) {
        [_EditingView createEditImage:^(UIImage *editImage) {
            finishImage(editImage);
        }];
    } else {
        finishImage(nil);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_EditingView]) {
        return YES;
    }
    return NO;
}

#pragma mark - LFEditToolbarDelegate 底部栏(action)

/** 一级菜单点击事件 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar mainDidSelectAtIndex:(NSUInteger)index
{
    /** 取消贴图激活 */
    [_EditingView stickerDeactivated];
    
    switch (index) {
        case LFEditToolbarType_draw:
        {
            /** 关闭涂抹 */
            _EditingView.splashEnable = NO;
            /** 打开绘画 */
            _EditingView.drawEnable = !_EditingView.drawEnable;
        }
            break;
        case LFEditToolbarType_sticker:
        {
            [self singlePressed];
            [self changeStickerMenu:YES animated:YES];
        }
            break;
        case LFEditToolbarType_text:
        {
            [self showTextBarController:nil];
        }
            break;
        case LFEditToolbarType_splash:
        {
            /** 关闭绘画 */
            _EditingView.drawEnable = NO;
            /** 打开涂抹 */
            _EditingView.splashEnable = !_EditingView.splashEnable;
        }
            break;
        case LFEditToolbarType_filter:
        {
            [self singlePressed];
            [self changeFilterMenu:YES animated:YES];
        }
            break;
        case LFEditToolbarType_crop:
        {
            [_EditingView setClipping:YES animated:YES];
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
        case LFEditToolbarType_draw:
        {
            [_EditingView drawUndo];
        }
            break;
        case LFEditToolbarType_sticker:
            break;
        case LFEditToolbarType_text:
            break;
        case LFEditToolbarType_splash:
        {
            [_EditingView splashUndo];
        }
            break;
        case LFEditToolbarType_crop:
            break;
        default:
            break;
    }
}
/** 二级菜单点击事件-按钮 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar subDidSelectAtIndex:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case LFEditToolbarType_draw:
            break;
        case LFEditToolbarType_sticker:
            break;
        case LFEditToolbarType_text:
            break;
        case LFEditToolbarType_splash:
        {
            [_EditingView setSplashStateType:(LFSplashStateType)indexPath.row];
        }
            break;
        case LFEditToolbarType_crop:
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
        case LFEditToolbarType_draw:
        {
            canUndo = [_EditingView drawCanUndo];
        }
            break;
        case LFEditToolbarType_sticker:
            break;
        case LFEditToolbarType_text:
            break;
        case LFEditToolbarType_splash:
        {
            canUndo = [_EditingView splashCanUndo];
        }
            break;
        case LFEditToolbarType_crop:
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

/** 二级菜单笔刷事件-绘画 */
- (void)lf_editToolbar:(LFEditToolbar *)editToolbar drawBrushDidChange:(LFBrush *)brush
{
    [_EditingView setDrawBrush:brush];
}

#pragma mark - 剪切底部栏（懒加载）
- (UIView *)edit_clipping_toolBar
{
    if (_edit_clipping_toolBar == nil) {
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            if (hasSafeArea) {
                safeAreaInsets = self.navigationController.view.safeAreaInsets;
            }
        }
        CGFloat h = 44.f + safeAreaInsets.bottom;
        _edit_clipping_toolBar = [[LFClipToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - h, self.view.width, h)];
        _edit_clipping_toolBar.alpha = 0.f;
        _edit_clipping_toolBar.delegate = self;
        _edit_clipping_toolBar.dataSource = self;
        
        /** 判断是否需要创建安全区域涂层 */
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, safeAreaInsets)) {
            _edit_clipping_safeAreaMaskView = [[LFSafeAreaMaskView alloc] initWithFrame:self.view.bounds];
            _edit_clipping_safeAreaMaskView.maskRect = _EditingView.frame;
            _edit_clipping_safeAreaMaskView.userInteractionEnabled = NO;
            [self.view insertSubview:_edit_clipping_safeAreaMaskView belowSubview:_EditingView];
        }
    }
    /** 默认不能重置，待进入剪切界面后重新获取 */
    _edit_clipping_toolBar.enableReset = NO;
    _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
    return _edit_clipping_toolBar;
}

#pragma mark - LFEditToolbarDataSource
- (BOOL)lf_clipToolbarCanRotate:(LFClipToolbar *)clipToolbar
{
    return [self operationBOOLForKey:LFPhotoEditCropCanRotateAttributeName];
}

- (BOOL)lf_clipToolbarCanAspectRatio:(LFClipToolbar *)clipToolbar
{
    return [self operationBOOLForKey:LFPhotoEditCropCanAspectRatioAttributeName];
}

#pragma mark - LFClipToolbarDelegate
/** 取消 */
- (void)lf_clipToolbarDidCancel:(LFClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == LFPhotoEditOperationType_crop && self.defaultOperationType == LFPhotoEditOperationType_crop) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有LFPhotoEditOperationType_crop的情况，无需返回，直接完成整个编辑 */
        [self cancelButtonClick];
    } else {
        [_EditingView cancelClipping:YES];
        [self changeClipMenu:NO];
        _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
        [self configDefaultOperation];
    }
}
/** 完成 */
- (void)lf_clipToolbarDidFinish:(LFClipToolbar *)clipToolbar
{
    if (self.initSelectedOperationType == 0 && self.operationType == LFPhotoEditOperationType_crop && self.defaultOperationType == LFPhotoEditOperationType_crop) { /** 证明initSelectedOperationType已消耗完毕，defaultOperationType是有值的。只有LFPhotoEditOperationType_crop的情况，无需返回，直接完成整个编辑 */
        [_EditingView setClipping:NO animated:NO];
        [self finishButtonClick];
    } else {
        [_EditingView setClipping:NO animated:YES];
        [self changeClipMenu:NO];
        _edit_clipping_toolBar.selectAspectRatio = [_EditingView aspectRatioIndex] > 0;
        [self configDefaultOperation];
    }
}
/** 重置 */
- (void)lf_clipToolbarDidReset:(LFClipToolbar *)clipToolbar
{
    [_EditingView reset];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
    _edit_clipping_toolBar.selectAspectRatio = NO;
}
/** 旋转 */
- (void)lf_clipToolbarDidRotate:(LFClipToolbar *)clipToolbar
{
    [_EditingView rotate];
    _edit_clipping_toolBar.enableReset = _EditingView.canReset;
}
/** 长宽比例 */
- (void)lf_clipToolbarDidAspectRatio:(LFClipToolbar *)clipToolbar
{
    if (_edit_clipping_toolBar.selectAspectRatio) {
        _edit_clipping_toolBar.selectAspectRatio = NO;
        [_EditingView setAspectRatioIndex:0];
        return;
    }
    NSArray *items = [_EditingView aspectRatioDescs];
    if (NSClassFromString(@"UIAlertController")) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle LFME_localizedStringForKey:@"_LFME_cancelButtonTitle"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self->_edit_clipping_toolBar.selectAspectRatio = NO;
            [self->_EditingView setAspectRatioIndex:0];
        }]];
        
        //Add each item to the alert controller
        NSString *languageName = nil;
        NSString *item = nil;
        for (NSInteger i=0; i<items.count; i++) {
            item = items[i];
            languageName = [@"_LFME_ratio_" stringByAppendingString:item];
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle LFME_localizedStringForKey:languageName value:item] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self->_edit_clipping_toolBar.selectAspectRatio = YES;
                [self->_EditingView setAspectRatioIndex:i+1];
            }];
            [alertController addAction:action];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            alertController.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *presentationController = [alertController popoverPresentationController];
            presentationController.sourceView = clipToolbar;
            presentationController.sourceRect = clipToolbar.clickViewRect;            
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        //TODO: Completely overhaul this once iOS 7 support is dropped
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:[NSBundle LFME_localizedStringForKey:@"_LFME_cancelButtonTitle"]
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *item in items) {
            [actionSheet addButtonWithTitle:item];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [actionSheet showFromRect:clipToolbar.frame inView:clipToolbar animated:YES];
        else
            [actionSheet showInView:self.view];
#pragma clang diagnostic pop
    }
}

#pragma mark - UIActionSheetDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        _edit_clipping_toolBar.selectAspectRatio = NO;
        [_EditingView setAspectRatioIndex:0];
    } else {
        _edit_clipping_toolBar.selectAspectRatio = YES;
        [_EditingView setAspectRatioIndex:buttonIndex];
    }
}
#pragma clang diagnostic pop

#pragma mark - 滤镜菜单（懒加载）
- (JRFilterBar *)edit_filter_toolBar
{
    if (_edit_filter_toolBar == nil) {
        CGFloat w=self.view.width, h=100.f;
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        _edit_filter_toolBar = [[JRFilterBar alloc] initWithFrame:CGRectMake(0, self.view.height, w, h) defalutEffectType:[_EditingView getFilterType] dataSource:@[
                                                                                                                                                                    @(LFFilterNameType_None),
                                                                                                                                                                    @(LFFilterNameType_LinearCurve),
                                                                                                                                                                    @(LFFilterNameType_Chrome),
                                                                                                                                                                    @(LFFilterNameType_Fade),
                                                                                                                                                                    @(LFFilterNameType_Instant),
                                                                                                                                                                    @(LFFilterNameType_Mono),
                                                                                                                                                                    @(LFFilterNameType_Noir),
                                                                                                                                                                    @(LFFilterNameType_Process),
                                                                                                                                                                    @(LFFilterNameType_Tonal),
                                                                                                                                                                    @(LFFilterNameType_Transfer),
                                                                                                                                                                    @(LFFilterNameType_CurveLinear),
                                                                                                                                                                    @(LFFilterNameType_Invert),
                                                                                                                                                                    @(LFFilterNameType_Monochrome),                                                                                    ]];
        CGFloat rgb = 34 / 255.0;
        _edit_filter_toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.85];
        _edit_filter_toolBar.defaultColor = self.cancelButtonTitleColorNormal;
        _edit_filter_toolBar.selectColor = self.oKButtonTitleColorNormal;
        _edit_filter_toolBar.delegate = self;
        _edit_filter_toolBar.dataSource = self;
    }
    return _edit_filter_toolBar;
}

#pragma mark - JRFilterBarDelegate
- (void)jr_filterBar:(JRFilterBar *)jr_filterBar didSelectImage:(UIImage *)image effectType:(NSInteger)effectType
{
    [_EditingView changeFilterType:effectType];
}

#pragma mark - JRFilterBarDataSource
- (UIImage *)jr_async_filterBarImageForEffectType:(NSInteger)type
{
    if (_filterSmallImage == nil) {
        CGSize size = CGSizeZero;
        CGSize imageSize = self.editImage.size;
        size.width = MIN(JR_FilterBar_MAX_WIDTH*[UIScreen mainScreen].scale, imageSize.width);
        size.height = ((int)(imageSize.height*size.width/imageSize.width))*1.f;
        
        UIGraphicsBeginImageContext(size);
        [self.editImage drawInRect:(CGRect){CGPointZero, size}];
        self.filterSmallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return lf_filterImageWithType(self.filterSmallImage, type);
}

- (NSString *)jr_filterBarNameForEffectType:(NSInteger)type
{
    NSString *defaultName = lf_descWithType(type);
    if (defaultName) {
        NSString *languageName = [@"_LFME_filter_" stringByAppendingString:defaultName];
        return [NSBundle LFME_localizedStringForKey:languageName];
    }
    return @"";
}

#pragma mark - 贴图菜单（懒加载）
- (LFStickerBar *)edit_sticker_toolBar
{
    if (_edit_sticker_toolBar == nil) {
        CGFloat row = 4;
        CGFloat w=self.view.width, h=lf_stickerSize*row+lf_stickerMargin*(row+1);
        if (@available(iOS 11.0, *)) {
            h += self.navigationController.view.safeAreaInsets.bottom;
        }
        CGRect frame = CGRectMake(0, self.view.height, w, h);
        
        if (self.stickerBarCacheResource) {
            _edit_sticker_toolBar = [[LFStickerBar alloc] initWithFrame:frame cacheResources:self.stickerBarCacheResource];
        } else {
            /** 设置默认贴图资源路径 */
            NSArray <LFStickerContent *>*stickerContents = [self operationArrayForKey:LFPhotoEditStickerContentsAttributeName];
            
            if (stickerContents == nil) {
                stickerContents = @[
                    [LFStickerContent stickerContentWithTitle:@"默认" contents:@[LFStickerContentDefaultSticker]],
                    [LFStickerContent stickerContentWithTitle:@"相册" contents:@[LFStickerContentAllAlbum]]
                ];
            }
            
            _edit_sticker_toolBar = [[LFStickerBar alloc] initWithFrame:frame resources:stickerContents];
        }
        
        _edit_sticker_toolBar.delegate = self;
    }
    return _edit_sticker_toolBar;
}

#pragma mark - LFStickerBarDelegate
- (void)lf_stickerBar:(LFStickerBar *)lf_stickerBar didSelectImage:(UIImage *)image
{
    if (image) {
        LFStickerItem *item = [LFStickerItem new];
        item.image = image;
        [_EditingView createSticker:item];
    }
    [self singlePressed];
}

#pragma mark - LFTextBarDelegate
/** 完成回调 */
- (void)lf_textBarController:(LFTextBar *)textBar didFinishText:(LFText *)text
{
    if (text) {
        LFStickerItem *item = [LFStickerItem new];
        item.text = text;
        /** 判断是否更改文字 */
        if (textBar.showText) {
            [_EditingView changeSelectSticker:item];
        } else {
            [_EditingView createSticker:item];
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

/** 输入数量已经达到最大值 */
- (void)lf_textBarControllerDidReachMaximumLimit:(LFTextBar *)textBar
{
    [self showInfoMessage:[NSBundle LFME_localizedStringForKey:@"_LFME_reachMaximumLimitTitle"]];
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
    if (_EditingView.drawCanUndo) [_edit_toolBar setRevokeAtIndex:LFEditToolbarType_draw];
    
    __weak typeof(self) weakSelf = self;
    lf_me_dispatch_cancel(self.delayCancelBlock);
    self.delayCancelBlock = lf_dispatch_block_t(1.f, ^{
        weakSelf.isHideNaviBar = NO;
        [weakSelf changedBarState];
    });
}

#pragma mark - LFPhotoEditStickerDelegate
/** 点击贴图 isActive=YES 选中的情况下点击 */
- (void)lf_photoEditStickerDidSelectViewIsActive:(BOOL)isActive
{
    _isHideNaviBar = NO;
    [self changedBarState];
    if (isActive) { /** 选中的情况下点击 */
        LFStickerItem *item = [_EditingView getSelectSticker];
        if (item.text) {
            [self showTextBarController:item.text];
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
    if (_EditingView.splashCanUndo) [_edit_toolBar setRevokeAtIndex:LFEditToolbarType_splash];
    
    __weak typeof(self) weakSelf = self;
    lf_me_dispatch_cancel(self.delayCancelBlock);
    self.delayCancelBlock = lf_dispatch_block_t(1.f, ^{
        weakSelf.isHideNaviBar = NO;
        [weakSelf changedBarState];
    });
}

#pragma mark - LFEditingViewDelegate
/** 开始编辑目标 */
- (void)lf_EditingViewWillBeginEditing:(LFEditingView *)EditingView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.edit_clipping_toolBar.alpha = 0.f;
    }];
    [_edit_clipping_safeAreaMaskView setShowMaskLayer:NO];
}
/** 停止编辑目标 */
- (void)lf_EditingViewDidEndEditing:(LFEditingView *)EditingView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.edit_clipping_toolBar.alpha = 1.f;
    }];
    [_edit_clipping_safeAreaMaskView setShowMaskLayer:YES];
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
}

/** 进入剪切界面 */
- (void)lf_EditingViewDidAppearClip:(LFEditingView *)EditingView
{
    _edit_clipping_toolBar.enableReset = EditingView.canReset;
}

#pragma mark - private
- (void)changedBarState
{
    [self changedBarStateWithAnimated:YES];
}
- (void)changedBarStateWithAnimated:(BOOL)animated
{
    lf_me_dispatch_cancel(self.delayCancelBlock);
    /** 隐藏贴图菜单 */
    [self changeStickerMenu:NO animated:animated];
    /** 隐藏滤镜菜单 */
    [self changeFilterMenu:NO animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            CGFloat alpha = self->_isHideNaviBar ? 0.f : 1.f;
            self->_edit_naviBar.alpha = alpha;
            self->_edit_toolBar.alpha = alpha;
        }];
    } else {
        CGFloat alpha = _isHideNaviBar ? 0.f : 1.f;
        _edit_naviBar.alpha = alpha;
        _edit_toolBar.alpha = alpha;
    }
}

- (void)changeClipMenu:(BOOL)isChanged
{
    [self changeClipMenu:isChanged animated:YES];
}

- (void)changeClipMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        /** 关闭所有编辑 */
        [_EditingView photoEditEnable:NO];
        /** 切换菜单 */
        [self.view addSubview:self.edit_clipping_toolBar];
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                self->_edit_clipping_toolBar.alpha = 1.f;
            }];
        } else {
            _edit_clipping_toolBar.alpha = 1.f;
        }
        [_edit_clipping_safeAreaMaskView setShowMaskLayer:YES];
        singleTapRecognizer.enabled = NO;
        [self singlePressedWithAnimated:animated];
    } else {
        if (_edit_clipping_toolBar.superview == nil) return;

        /** 开启编辑 */
        [_EditingView photoEditEnable:YES];
        
        singleTapRecognizer.enabled = YES;
        [_edit_clipping_safeAreaMaskView setShowMaskLayer:NO];
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_clipping_toolBar.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self->_edit_clipping_toolBar removeFromSuperview];
            }];            
        } else {
            [_edit_clipping_toolBar removeFromSuperview];
        }
        
        [self singlePressedWithAnimated:animated];
    }
}

- (void)changeStickerMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        [self.view addSubview:self.edit_sticker_toolBar];
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.height-frame.size.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_sticker_toolBar.frame = frame;
            }];
        } else {
            _edit_sticker_toolBar.frame = frame;
        }
    } else {
        if (_edit_sticker_toolBar.superview == nil) return;
        
        CGRect frame = self.edit_sticker_toolBar.frame;
        frame.origin.y = self.view.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_sticker_toolBar.frame = frame;
            } completion:^(BOOL finished) {
                self.stickerBarCacheResource = self->_edit_sticker_toolBar.cacheResources;
                [self->_edit_sticker_toolBar removeFromSuperview];
                self->_edit_sticker_toolBar = nil;
            }];
        } else {
            self.stickerBarCacheResource = _edit_sticker_toolBar.cacheResources;
            [_edit_sticker_toolBar removeFromSuperview];
            _edit_sticker_toolBar = nil;
        }
    }
}

- (void)changeFilterMenu:(BOOL)isChanged animated:(BOOL)animated
{
    if (isChanged) {
        [self.view addSubview:self.edit_filter_toolBar];
        CGRect frame = self.edit_filter_toolBar.frame;
        frame.origin.y = self.view.height-frame.size.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_filter_toolBar.frame = frame;
            }];
        } else {
            _edit_filter_toolBar.frame = frame;
        }
    } else {
        if (_edit_filter_toolBar.superview == nil) return;
        
        CGRect frame = self.edit_filter_toolBar.frame;
        frame.origin.y = self.view.height;
        if (animated) {
            [UIView animateWithDuration:.25f animations:^{
                self->_edit_filter_toolBar.frame = frame;
            } completion:^(BOOL finished) {
                [self->_edit_filter_toolBar removeFromSuperview];
                self->_edit_filter_toolBar = nil;
            }];
        } else {
            [_edit_filter_toolBar removeFromSuperview];
            _edit_filter_toolBar = nil;
        }
    }
}

- (void)showTextBarController:(LFText *)text
{
    static NSInteger LFTextBarTag = 32735;
    if ([self.view viewWithTag:LFTextBarTag]) {
        return;
    }
    
    LFTextBar *textBar = [[LFTextBar alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, self.view.height) layout:^(LFTextBar *textBar) {
        textBar.oKButtonTitleColorNormal = self.oKButtonTitleColorNormal;
        textBar.cancelButtonTitleColorNormal = self.cancelButtonTitleColorNormal;
        textBar.oKButtonTitle = [NSBundle LFME_localizedStringForKey:@"_LFME_oKButtonTitle"];
        textBar.cancelButtonTitle = [NSBundle LFME_localizedStringForKey:@"_LFME_cancelButtonTitle"];
        textBar.customTopbarHeight = self->_edit_naviBar.height;
        textBar.naviHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    }];
    textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textBar.showText = text;
    textBar.delegate = self;
    textBar.tag = LFTextBarTag;
    
    if (text == nil) {
        /** 设置默认文字颜色 */
        LFPhotoEditOperationSubType subType = [self operationSubTypeForKey:LFPhotoEditTextColorAttributeName];
        
        NSInteger index = 0;
        switch (subType) {
            case LFPhotoEditOperationSubTypeTextWhiteColor: index = 0; break;
            case LFPhotoEditOperationSubTypeTextBlackColor: index = 1; break;
            case LFPhotoEditOperationSubTypeTextRedColor: index = 2; break;
            case LFPhotoEditOperationSubTypeTextLightYellowColor: index = 3; break;
            case LFPhotoEditOperationSubTypeTextYellowColor: index = 4; break;
            case LFPhotoEditOperationSubTypeTextLightGreenColor: index = 5; break;
            case LFPhotoEditOperationSubTypeTextGreenColor: index = 6; break;
            case LFPhotoEditOperationSubTypeTextAzureColor: index = 7; break;
            case LFPhotoEditOperationSubTypeTextRoyalBlueColor: index = 8; break;
            case LFPhotoEditOperationSubTypeTextBlueColor: index = 9; break;
            case LFPhotoEditOperationSubTypeTextPurpleColor: index = 10; break;
            case LFPhotoEditOperationSubTypeTextLightPinkColor: index = 11; break;
            case LFPhotoEditOperationSubTypeTextVioletRedColor: index = 12; break;
            case LFPhotoEditOperationSubTypeTextPinkColor: index = 13; break;
            default:
                break;
        }
        [textBar setTextSliderColorAtIndex:index];
    }
    

    [self.view addSubview:textBar];
    
    [textBar becomeFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        textBar.y = 0;
    } completion:^(BOOL finished) {
        /** 隐藏顶部栏 */
        self->_isHideNaviBar = YES;
        [self changedBarState];
    }];
}

#pragma mark - 配置数据
- (LFPhotoEditOperationSubType)operationSubTypeForKey:(LFPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (LFPhotoEditOperationSubType)[obj integerValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:LFPhotoEditDrawColorAttributeName]
        || [key isEqualToString:LFPhotoEditDrawBrushAttributeName]
        || [key isEqualToString:LFPhotoEditTextColorAttributeName]
        || [key isEqualToString:LFPhotoEditSplashAttributeName]
        || [key isEqualToString:LFPhotoEditFilterAttributeName]
        || [key isEqualToString:LFPhotoEditCropAspectRatioAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is LFPhotoEditOperationSubType", key);
        #pragma clang diagnostic pop
    }
    return 0;
}

//- (NSString *)operationStringForKey:(LFPhotoEditOperationStringKey)key
//{
//    id obj = [self.operationAttrs objectForKey:key];
//    if ([obj isKindOfClass:[NSString class]]) {
//        return (NSString *)obj;
//    } else if (obj) {
//        #pragma clang diagnostic push
//        #pragma clang diagnostic ignored "-Wunused-variable"
//
//        BOOL isContain = [key isEqualToString:LFPhotoEditStickerAttributeName];
//        NSAssert(!isContain, @"The type corresponding to this key %@ is NSString", key);
//        #pragma clang diagnostic pop
//    }
//    return nil;
//}

- (NSArray *)operationArrayForKey:(LFPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:LFPhotoEditStickerContentsAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSArray", key);
        #pragma clang diagnostic pop
    }
    return nil;
}

- (BOOL)operationBOOLForKey:(LFPhotoEditOperationStringKey)key
{
    id obj = [self.operationAttrs objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    } else if (obj) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wunused-variable"
                
        BOOL isContain = [key isEqualToString:LFPhotoEditCropCanRotateAttributeName]
        || [key isEqualToString:LFPhotoEditCropCanAspectRatioAttributeName];
        NSAssert(!isContain, @"The type corresponding to this key %@ is NSString", key);
        #pragma clang diagnostic pop
    } else {
        if ([key isEqualToString:LFPhotoEditCropCanRotateAttributeName]) {
            return YES;
        } else if ([key isEqualToString:LFPhotoEditCropCanAspectRatioAttributeName]) {
            return YES;
        }
    }
    return NO;
}

@end
