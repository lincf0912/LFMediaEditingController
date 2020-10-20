//
//  LFBaseEditingController.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/6/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFBaseEditingController.h"
#import "LFMediaEditingHeader.h"
#import "UIDevice+LFMEOrientation.h"
#import "LFEasyNoticeBar.h"
#import "UIViewController+LFPresentation.h"

#import "LFBrushCache.h"

@interface LFBaseEditingController ()
{
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    UIProgressView *_ProgressView;
    
}
/** 默认编辑屏幕方向 */
@property (nonatomic, assign) UIInterfaceOrientation orientation;


@end

@implementation LFBaseEditingController

- (instancetype)init
{
    return [self initWithOrientation:UIInterfaceOrientationPortrait];
}

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation
{
    self = [super init];
    if (self) {
        _orientation = orientation;
        /** 因数据可以多次重复编辑，暂时未能处理横竖屏切换的问题。 */
        [UIDevice LFME_setOrientation:orientation];
        _oKButtonTitleColorNormal = [UIColor colorWithRed:(26/255.0) green:(173/255.0) blue:(25/255.0) alpha:1.0];
        _cancelButtonTitleColorNormal = [UIColor colorWithWhite:0.8f alpha:1.f];
        /** 创建笔刷缓存 */
        [LFBrushCache share].countLimit = 20;
        if (@available(iOS 7.0, *)) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        /** 刘海屏的顶部一直会存在安全区域，window的显示区域不在刘海屏范围，调整window的层级无法遮挡状态栏。 */
        if (@available(iOS 11.0, *)) {
            if (hasSafeArea) {
                self.isHiddenStatusBar = YES;
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSAssert(self.navigationController, @"You must wrap it with UINavigationController");
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 隐藏状态栏而不改变安全区域的高度
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar + 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (@available(iOS 13.0, *)) {
        if (isiPhone && self.navigationController.modalPresentationStyle == UIModalPresentationPageSheet) {
            // 不允许下拉关闭
            self.modalInPresentation = YES;
            // 彻底关闭下拉手势
            self.lf_dropShadowPanGestureRecognizer.enabled = NO;            
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    if (@available(iOS 13.0, *)) {
        // 重新开启下拉手势
        self.lf_dropShadowPanGestureRecognizer.enabled = YES;
    }
}

- (void)dealloc
{
    /** 销毁笔刷缓存 */
    [LFBrushCache free];
    [self hideProgressHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (BOOL)shouldAutorotate
{
    /** 必须要为YES，开启接受屏幕方向转换，否则会受到其他能横屏的界面影响，无法更正回来 */
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    switch (self.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            mask = UIInterfaceOrientationMaskLandscape;
            break;
        case UIInterfaceOrientationLandscapeRight:
            mask = UIInterfaceOrientationMaskLandscape;
            break;
        default:
            break;
    }
    return mask;
}

/**
 从状态栏下拉或底部栏上滑，跟系统的下拉通知中心手势和上滑控制中心手势冲突。
 设置后下拉状态栏只会展示指示器，继续下拉才能将通知中心拉出来。如果返回UIRectEdgeNone则会直接下拉出来。
 */
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}

#pragma public
- (void)showProgressHUDText:(NSString *)text
{
    [self showProgressHUDText:text isTop:NO needProcess:NO];
}

- (void)showProgressHUD
{
    [self showProgressHUDText:nil isTop:NO needProcess:NO];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
        [_ProgressView setProgress:0.f];
    }
}

- (void)showProgressVideoHUD
{
    [self showProgressHUDText:nil isTop:NO needProcess:YES];
}

- (void)setProgress:(float)progress
{
    [_ProgressView setProgress:progress animated:YES];
}

- (void)showInfoMessage:(NSString *)text
{
    LFEasyNoticeBarConfig config = LFEasyNoticeBarConfigDefault();
    config.title = text;
    config.type = LFEasyNoticeBarDisplayTypeInfo;
    [LFEasyNoticeBar showAnimationWithConfig:config];
}

- (void)showErrorMessage:(NSString *)text
{
    LFEasyNoticeBarConfig config = LFEasyNoticeBarConfigDefault();
    config.title = text;
    config.type = LFEasyNoticeBarDisplayTypeError;
    [LFEasyNoticeBar showAnimationWithConfig:config];
}

#pragma mark - private
- (void)showProgressHUDText:(NSString *)text isTop:(BOOL)isTop needProcess:(BOOL)needProcess
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
    if (needProcess) {
        _HUDContainer.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 120) / 2, ([[UIScreen mainScreen] bounds].size.height - 90) / 2, 120.f, 100.f);
        if (!_ProgressView) {
            _ProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(_HUDLabel.frame), CGRectGetWidth(_HUDContainer.frame)-20.f, 2.5f)];
            [_HUDContainer addSubview:_ProgressView];
        }
    }
    
    _HUDLabel.text = text ? text : [NSBundle LFME_localizedStringForKey:@"_LFME_processHintStr"];
    
    [_HUDIndicatorView startAnimating];
    UIView *view = isTop ? [[UIApplication sharedApplication] keyWindow] : self.view;
    [view addSubview:_progressHUD];
}

@end
