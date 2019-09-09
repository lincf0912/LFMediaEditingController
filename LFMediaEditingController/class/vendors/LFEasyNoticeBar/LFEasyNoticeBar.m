//
//  LFEasyNoticeBar.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/9.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFEasyNoticeBar.h"

CGFloat const LFEasyNoticeBarWidenSize = 50.0;

LFEasyNoticeBarConfig LFEasyNoticeBarConfigDefault(void) {
    return (LFEasyNoticeBarConfig){
        nil, LFEasyNoticeBarDisplayTypeInfo, 20.0, [UIColor blackColor], [UIColor whiteColor]
    };
};

@interface LFEasyNoticeBar ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) UIStatusBarStyle currentStatusBarStyle;

@end

@implementation LFEasyNoticeBar

+ (NSBundle *)lf_noticeBarBundle {
    static NSBundle *noticeBarBundle = nil;
    if (noticeBarBundle == nil) {
        noticeBarBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LFEasyNoticeBar" ofType:@"bundle"]];
        if (noticeBarBundle == nil) {
            return [NSBundle bundleForClass:[self class]];
        }
    }
    return noticeBarBundle;
}

- (UIImage *)lf_noticeBarImageNamed:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:[[[self class] lf_noticeBarBundle] pathForResource:name ofType:nil]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithConfig:(LFEasyNoticeBarConfig)config
{
    self = [super init];
    if (self) {
        _config = config;
        [self customInit];
    }
    return self;
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    [self updateLayoutSubviews];
}

- (void)customInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.44;
}

- (void)configureSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = _config.title;
    titleLabel.textColor = _config.textColor;
    titleLabel.minimumScaleFactor = 0.55;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UIImage *image = nil;
    switch (_config.type) {
        case LFEasyNoticeBarDisplayTypeInfo:
        {
            image = [self lf_noticeBarImageNamed:@"info@2x.png"];
        }
            break;
        case LFEasyNoticeBarDisplayTypeSuccess:
        {
            image = [self lf_noticeBarImageNamed:@"success@2x.png"];
        }
            break;
        case LFEasyNoticeBarDisplayTypeWarning:
        {
            image = [self lf_noticeBarImageNamed:@"warning@2x.png"];
        }
            break;
        case LFEasyNoticeBarDisplayTypeError:
        {
            image = [self lf_noticeBarImageNamed:@"error@2x.png"];
        }
            break;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    _imageView = imageView;
    
    [self updateLayoutSubviews];
}

- (void)showWithDuration:(NSTimeInterval)duration
{
    [[self class] hideAll];
    
    [self configureSubviews];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.currentStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = self.config.statusBarStyle;
    
    [keyWindow addSubview:self];
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    self.transform = transform;
    
    [UIView animateWithDuration:0.65 delay:0.0 usingSpringWithDamping:0.58 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = transform;
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeFromSuperview];
            }
        }];
    }];
}

#pragma mark - public
+ (void)showAnimationWithConfig:(LFEasyNoticeBarConfig)config
{
    LFEasyNoticeBar *lf_noticeBar = [[self alloc] initWithConfig:config];
    [lf_noticeBar showWithDuration:2.0];
}

+ (void)hideAll
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSArray *subviews = keyWindow.subviews;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[self class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Override

- (void)removeFromSuperview {
    [UIApplication sharedApplication].statusBarStyle = self.currentStatusBarStyle;
    
    [super removeFromSuperview];
}


#pragma mark - private

- (void)updateLayoutSubviews
{
    BOOL isVerticalScreen = [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height;
    CGFloat navigationBarHeight = isVerticalScreen ? 44.0 : 34.0;
    CGFloat statusBarHeight = isVerticalScreen ? 20.0 : 0.0;
    
    CGFloat imageWidth = 21.0;
    CGFloat imageOriginX = _config.margin + 10.0 + LFEasyNoticeBarWidenSize;
    if (@available(iOS 11.0, *)) {
        statusBarHeight = self.safeAreaInsets.top;
    }
    CGFloat imageOriginY = statusBarHeight + (navigationBarHeight-imageWidth)/2 + LFEasyNoticeBarWidenSize;
    [_imageView setFrame:CGRectMake(imageOriginX, imageOriginY, imageWidth, imageWidth)];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width + LFEasyNoticeBarWidenSize*2;
    
    CGFloat titleLabelOriginX = CGRectGetMaxX(_imageView.frame) + 10;
    CGFloat titleLabelOriginY = statusBarHeight + LFEasyNoticeBarWidenSize;
    CGFloat titleLabelWidth = screenWidth - titleLabelOriginX - 10;
    CGFloat titleLabelHeight = navigationBarHeight;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [_titleLabel setFrame:CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, titleLabelHeight)];
    
    self.frame = CGRectMake(-LFEasyNoticeBarWidenSize, -LFEasyNoticeBarWidenSize, screenWidth, statusBarHeight+navigationBarHeight+LFEasyNoticeBarWidenSize);
}

@end
