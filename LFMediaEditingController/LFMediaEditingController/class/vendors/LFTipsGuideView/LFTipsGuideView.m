//
//  LFTipsGuideView.m
//  LFTipsGuideView
//
//  Created by TsanFeng Lam on 2020/2/3.
//  Copyright © 2020 lincf0912. All rights reserved.
//

#import "LFTipsGuideView.h"

@interface NSBundle (LFTipsGuideView)
+ (UIImage *)LF_tipGuideViewBundleImageNamed:(NSString *)name;
+ (UIImage *)LF_tipGuideViewBundleImageNamed:(NSString *)name inDirectory:(NSString *)subpath;
@end

@implementation NSBundle (LFTipsGuideView)

+ (instancetype)LF_tipsGuideViewBundle
{
    static NSBundle *lfTipsGuideViewBundle = nil;
    if (lfTipsGuideViewBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        lfTipsGuideViewBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[LFTipsGuideView class]] pathForResource:@"LFTipsGuideView" ofType:@"bundle"]];
    }
    return lfTipsGuideViewBundle;
}

+ (UIImage *)LF_tipGuideViewBundleImageNamed:(NSString *)name inDirectory:(NSString *)subpath
{
    //  [NSBundle LF_tipGuideViewBundleImageNamed:[NSString stringWithFormat:@"%@/%@", kBundlePath, name]]
    NSString *extension = name.length ? (name.pathExtension.length ? name.pathExtension : @"png") : nil;
    NSString *defaultName = [name stringByDeletingPathExtension];
    NSString *bundleName = [defaultName stringByAppendingString:@"@2x"];
    //    CGFloat scale = [UIScreen mainScreen].scale;
    //    if (scale == 3) {
    //        bundleName = [name stringByAppendingString:@"@3x"];
    //    } else {
    //        bundleName = [name stringByAppendingString:@"@2x"];
    //    }
    UIImage *image = [UIImage imageWithContentsOfFile:[[self LF_tipsGuideViewBundle] pathForResource:bundleName ofType:extension inDirectory:subpath]];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[[self LF_tipsGuideViewBundle] pathForResource:defaultName ofType:extension inDirectory:subpath]];
    }
    if (image == nil) {
        image = [NSBundle LF_tipGuideViewBundleImageNamed:name];
    }
    return image;
}

+ (UIImage *)LF_tipGuideViewBundleImageNamed:(NSString *)name
{
    return [self LF_tipGuideViewBundleImageNamed:name inDirectory:nil];
}

@end

@interface UIImage (LFTipGuideViewMask)
- (UIImage *)LF_tipGuideViewMaskImage:(UIColor *)maskColor;
@end

@implementation UIImage (LFTipGuideViewMask)

- (UIImage *)LF_tipGuideViewMaskImage:(UIColor *)maskColor
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, maskColor.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end

@interface LFTipsGuideView ()

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIImageView *btnMaskView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UILabel *tipsLabel;


@property (nonatomic, assign) CGRect maskRect;

@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *rightMaskView;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray *rectsArr;
@property (nonatomic, strong) NSArray *tipsArr;
@property (nonatomic, copy) NSString *tipsStr;

@end

@implementation LFTipsGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = 0;
        self.count = 0;
        self.layer.zPosition = 1;
        [self addSubview:self.topMaskView];
        [self addSubview:self.bottomMaskView];
        [self addSubview:self.leftMaskView];
        [self addSubview:self.rightMaskView];
        [self addSubview:self.okBtn];
        [self addSubview:self.btnMaskView];
        [self addSubview:self.arrowView];
        [self addSubview:self.tipsLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = _parentView.bounds;
    
    _btnMaskView.frame = self.maskRect;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _topMaskView.frame = CGRectMake(0, 0, width, CGRectGetMinY(_btnMaskView.frame));
    
    _bottomMaskView.frame = CGRectMake(0, CGRectGetMaxY(_btnMaskView.frame), width, height-CGRectGetMaxY(_btnMaskView.frame));
    
    _leftMaskView.frame = CGRectMake(0, CGRectGetMinY(_btnMaskView.frame), CGRectGetMinX(_btnMaskView.frame), CGRectGetHeight(_btnMaskView.frame));
    
    _rightMaskView.frame = CGRectMake(CGRectGetMaxX(_btnMaskView.frame), CGRectGetMinY(_btnMaskView.frame), width-CGRectGetMaxX(_btnMaskView.frame), CGRectGetHeight(_btnMaskView.frame));
    
    
    CGFloat label_width = MAX(CGRectGetWidth(_btnMaskView.frame), width * 3 / 4);
    _tipsLabel.frame = CGRectMake( (width - label_width) / 2 ,0, label_width, 20);
    
    _tipsLabel.text = self.tipsStr;
    [_tipsLabel sizeToFit];
    
    CGPoint self_Center = self.center;
    CGPoint btnMask_Center = _btnMaskView.center;
    
    CGFloat arrowTopMargin = 8.0;
    CGFloat tipsLabelLeftMargin = 6.0;
    CGFloat tipsLabelTopMargin = 10.0;
    CGFloat okBtnBottomMargin = 30.0;
    
    if (btnMask_Center.x <= self_Center.x && btnMask_Center.y <= self_Center.y) {
        
        
        [_arrowView setImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"left_top"]];
        
        {
            CGRect tmpRect = _arrowView.frame;
            tmpRect.origin = CGPointMake(_btnMaskView.center.x, CGRectGetMaxY(_btnMaskView.frame)+arrowTopMargin);
            _arrowView.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _tipsLabel.frame;
            tmpRect.origin = CGPointMake(MIN(CGRectGetMaxX(_arrowView.frame)+tipsLabelLeftMargin,width-tmpRect.size.width-tipsLabelLeftMargin), CGRectGetMaxY(_arrowView.frame)+tipsLabelTopMargin);
            _tipsLabel.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _okBtn.frame;
            tmpRect.origin.x = (width-tmpRect.size.width)/2;
            tmpRect.origin.y = CGRectGetMaxY(_tipsLabel.frame)+okBtnBottomMargin;
            _okBtn.frame = tmpRect;
        }
        
    }
    
    if (btnMask_Center.x >= self_Center.x && btnMask_Center.y <= self_Center.y){
        
        [_arrowView setImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"right_top"]];
        
        {
            CGRect tmpRect = _arrowView.frame;
            tmpRect.origin = CGPointMake(_btnMaskView.center.x-tmpRect.size.width, CGRectGetMaxY(_btnMaskView.frame)+arrowTopMargin);
            _arrowView.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _tipsLabel.frame;
            tmpRect.origin = CGPointMake(MAX(CGRectGetMinX(_arrowView.frame)-tipsLabelLeftMargin-tmpRect.size.width,tipsLabelLeftMargin), CGRectGetMaxY(_arrowView.frame)+tipsLabelTopMargin);
            _tipsLabel.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _okBtn.frame;
            tmpRect.origin.x = (width-tmpRect.size.width)/2;
            tmpRect.origin.y = CGRectGetMaxY(_tipsLabel.frame)+okBtnBottomMargin;
            _okBtn.frame = tmpRect;
        }
    }
    
    if (btnMask_Center.x <= self_Center.x && btnMask_Center.y >= self_Center.y) {
        
        [_arrowView setImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"left_down"]];
        
        {
            CGRect tmpRect = _arrowView.frame;
            tmpRect.origin = CGPointMake(_btnMaskView.center.x, CGRectGetMinY(_btnMaskView.frame)-arrowTopMargin-tmpRect.size.height);
            _arrowView.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _tipsLabel.frame;
            tmpRect.origin = CGPointMake(MIN(CGRectGetMaxX(_arrowView.frame)+tipsLabelLeftMargin,width-tmpRect.size.width-tipsLabelLeftMargin), CGRectGetMinY(_arrowView.frame)-tipsLabelTopMargin-tmpRect.size.height);
            _tipsLabel.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _okBtn.frame;
            tmpRect.origin.x = (width-tmpRect.size.width)/2;
            tmpRect.origin.y = CGRectGetMinY(_tipsLabel.frame)-okBtnBottomMargin-tmpRect.size.height;
            _okBtn.frame = tmpRect;
        }
        
    }
    
    if (btnMask_Center.x >= self_Center.x && btnMask_Center.y >= self_Center.y) {
        
        
        [_arrowView setImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"right_down"]];
        
        {
            CGRect tmpRect = _arrowView.frame;
            tmpRect.origin = CGPointMake(_btnMaskView.center.x-tmpRect.size.width, CGRectGetMinY(_btnMaskView.frame)-arrowTopMargin-tmpRect.size.height);
            _arrowView.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _tipsLabel.frame;
            tmpRect.origin = CGPointMake(MAX(CGRectGetMinX(_arrowView.frame)-tipsLabelLeftMargin-tmpRect.size.width, tipsLabelLeftMargin), CGRectGetMinY(_arrowView.frame)-tipsLabelTopMargin-tmpRect.size.height);
            _tipsLabel.frame = tmpRect;
        }
        
        {
            CGRect tmpRect = _okBtn.frame;
            tmpRect.origin.x = (width-tmpRect.size.width)/2;
            tmpRect.origin.y = CGRectGetMinY(_tipsLabel.frame)-okBtnBottomMargin-tmpRect.size.height;
            _okBtn.frame = tmpRect;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self next];
}


- (void)showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr{
    
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:views.count];
    for (int i = 0; i < [views count]; i++) {
        UIView *view = views[i];
        CGRect maskRect = view.frame;
        maskRect.size = CGSizeMake(floor(maskRect.size.width + 10), floor(maskRect.size.height + 10));
        maskRect.origin = CGPointMake(floor(maskRect.origin.x - 5), floor(maskRect.origin.y - 5));
        [rects addObject:[NSValue valueWithCGRect:maskRect]];
    }
    [self showInView:view maskRects:rects withTips:tipsArr];
}

- (void)showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr{
    
    self.parentView = view;
    self.rectsArr = rects;
    self.tipsArr = tipsArr;
    // 补充提示
//    if ([rects count] > [tipsArr count]){
//        self.tipsArr = [NSMutableArray arrayWithArray:tipsArr];
//        NSInteger delta = rects.count - tipsArr.count;
//        for (int i= 0; i<delta; i++) {
//            [self.tipsArr addObject:@""];
//        }
//    }
    self.count = MIN(rects.count, tipsArr.count);
    
    [self next];
    if (self.count) {
        [self show];
    }
}

- (void)show {
    self.alpha = 0;
    [self.parentView addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {

    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        self.didShowTips = nil;
        if (self.completion) {
            self.completion();
            self.completion = nil;
        }
    }];
}

- (void)next{
    
    if (self.index >= self.count) {
        [self dismiss];
    }else{
        self.tipsStr = self.tipsArr[self.index];
        self.maskRect = [self.rectsArr[self.index] CGRectValue];
        [self layoutSubviews];
        if (self.didShowTips) {
            self.didShowTips(self.index);
        }
    }
    self.index++;
}

#pragma mark - getter and setter

- (UIButton *)okBtn {
    if (!_okBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"okBtn"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        _okBtn = btn;
    }
    return _okBtn;
}

- (UIImageView *)btnMaskView {
    if (!_btnMaskView) {
        UIImage *image = [NSBundle LF_tipGuideViewBundleImageNamed:@"whiteMask2"];
        image = [image LF_tipGuideViewMaskImage:[[UIColor blackColor] colorWithAlphaComponent:0.80]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        _btnMaskView = imageView;
    }
    return _btnMaskView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[NSBundle LF_tipGuideViewBundleImageNamed:@"right_down"]];
        _arrowView = imageView;
    }
    return _arrowView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.text = @"";
        tipsLabel.numberOfLines = 0;
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [tipsLabel sizeToFit];
        _tipsLabel = tipsLabel;
        
    }
    return _tipsLabel;
}

- (UIView *)topMaskView {
    if (!_topMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.80];
        _topMaskView = view;
    }
    return _topMaskView;
}

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.80];
        _bottomMaskView = view;
    }
    return _bottomMaskView;
}

- (UIView *)leftMaskView {
    if (!_leftMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.80];
        _leftMaskView = view;
    }
    return _leftMaskView;
}

- (UIView *)rightMaskView {
    if (!_rightMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.80];
        _rightMaskView = view;
    }
    return _rightMaskView;
}

@end
