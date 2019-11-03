//
//  LFEditToolbar.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/14.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFEditToolbar.h"
#import "UIView+LFMEFrame.h"
#import "LFMediaEditingHeader.h"
#import "JRPickColorView.h"
#import "SPDropMenu.h"

#import "LFPaintBrush.h"
#import "LFStampBrush.h"
#import "LFHighlightBrush.h"
#import "LFChalkBrush.h"
#import "LFFluorescentBrush.h"

#define EditToolbarButtonImageNormals @[@"EditImagePenToolBtn.png", @"EditImageEmotionToolBtn.png", @"EditImageTextToolBtn.png", @"EditImageMosaicToolBtn.png", @"EditImageCropToolBtn.png", @"EditImageAudioToolBtn.png", @"EditVideoCropToolBtn.png", @"EditImageFilterToolBtn.png", @"EditImageRateToolBtn.png"]
#define EditToolbarButtonImageHighlighted @[@"EditImagePenToolBtn_HL.png", @"EditImageEmotionToolBtn_HL.png", @"EditImageTextToolBtn_HL.png", @"EditImageMosaicToolBtn_HL.png", @"EditImageCropToolBtn_HL.png", @"EditImageAudioToolBtn_HL.png", @"EditVideoCropToolBtn_HL.png", @"EditImageFilterToolBtn_HL.png", @"EditImageRateToolBtn_HL.png"]



#define EditToolbarBrushTitles @[@"_LFME_brush_Paint", @"_LFME_brush_Highlight", @"_LFME_brush_Chalk", @"_LFME_brush_Fluorescent", @"_LFME_brush_Stamp"]

#define EditToolbarBrushImageNormals @[@"EditImagePenTool_Paint.png", @"EditImagePenTool_Highlight.png", @"EditImagePenTool_Chalk.png", @"EditImagePenTool_Fluorescent.png", @"EditImagePenTool_Stamp.png"]
#define EditToolbarBrushImageHighlighted @[@"EditImagePenTool_Paint_HL.png", @"EditImagePenTool_Highlight_HL.png", @"EditImagePenTool_Chalk_HL.png", @"EditImagePenTool_Fluorescent_HL.png", @"EditImagePenTool_Stamp_HL.png"]

#define EditToolbarStampBrushImageNormals @[@"EditImageStampBrushAnimal.png", @"EditImageStampBrushFruit.png", @"EditImageStampBrushHeart.png"]

#define kToolbar_MainHeight 44
#define kToolbar_SubHeight 55

#define kToolbar_RateTips(r) [NSString stringWithFormat:@"x %.1f", r]

#define kToolbar_SelectedColor [UIColor colorWithRed:(26/255.0) green:(173/255.0) blue:(25/255.0) alpha:1.0]
#define kToolbar_NormalsColor [UIColor whiteColor]

@interface LFEditToolbar () <JRPickColorViewDelegate>

/** 一级菜单 */
@property (nonatomic, weak) UIView *edit_menu;

/** 二级菜单 */
@property (nonatomic, weak) UIView *edit_drawMenu;
@property (nonatomic, weak) UIButton *edit_drawMenu_revoke;
/** 笔刷类型 */
@property (nonatomic, weak) UIButton *edit_drawMenu_brush;
/** 绘画拾色器 */
@property (nonatomic, weak) JRPickColorView *draw_colorSlider;
/** 图章类型 */
@property (nonatomic, weak) UIView *draw_stampView;
@property (nonatomic, assign) EditToolbarBrushType edit_drawMenu_brushType;
@property (nonatomic, assign) EditToolbarStampBrushType edit_drawMenu_stampBrushType;

@property (nonatomic, weak) UIView *edit_splashMenu;
@property (nonatomic, weak) UIButton *edit_splashMenu_revoke;
/** 进度条 */
@property (nonatomic, weak) UIView *edit_rateMenu;
@property (nonatomic, weak) UISlider *edit_rateMenu_slider;
@property (nonatomic, weak) UIButton *edit_rateMenu_tipsButton;

/** 当前激活绘画菜单按钮 */
@property (nonatomic, weak) UIButton *edit_drawMenu_action_button;
/** 当前激活模糊菜单按钮 */
@property (nonatomic, weak) UIButton *edit_splashMenu_action_button;

/** 当前显示菜单 */
@property (nonatomic, weak) UIView *selectMenu;
/** 当前点击按钮 */
@property (nonatomic, weak) UIButton *selectButton;


@property (nonatomic, assign) LFEditToolbarType type;
@property (nonatomic, strong) NSArray *mainImageNormals;
@property (nonatomic, strong) NSArray *mainImageHighlighted;

@end

@implementation LFEditToolbar

- (instancetype)initWithType:(LFEditToolbarType)type
{
    self = [self init];
    if (self) {
        _type = type;
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat height = kToolbar_MainHeight+kToolbar_SubHeight;
    self = [super initWithFrame:(CGRect){{0, [UIScreen mainScreen].bounds.size.height-height}, {[UIScreen mainScreen].bounds.size.width, height}}];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = kToolbar_MainHeight+kToolbar_SubHeight;
    
    if (@available(iOS 11.0, *)) {
        height += self.safeAreaInsets.bottom;
    }
    
    self.frame = (CGRect){{0, self.superview.frame.size.height-height}, {self.superview.frame.size.width, height}};
    self.edit_menu.frame = CGRectMake(0, kToolbar_SubHeight, self.width, height-kToolbar_SubHeight);
}

- (void)customInit
{
    _mainImageNormals = EditToolbarButtonImageNormals;
    _mainImageHighlighted = EditToolbarButtonImageHighlighted;
    [self mainBar];
    [self subBar];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

#pragma mark - 菜单创建
- (void)mainBar
{
    CGFloat height = kToolbar_MainHeight;
    if (@available(iOS 11.0, *)) {
        height += self.safeAreaInsets.bottom;
    }
    UIView *edit_menu = [[UIView alloc] initWithFrame:CGRectMake(0, kToolbar_SubHeight, self.width, height)];
    edit_menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    CGFloat rgb = 34 / 255.0;
    edit_menu.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.85];
    
    NSInteger buttonCount = 0;
    NSMutableArray <NSNumber *>*_imageIndexs = [@[] mutableCopy];
    NSMutableArray <NSNumber *>*_selectIndexs = [@[] mutableCopy];
    
    if (self.type&LFEditToolbarType_draw) {
        [_imageIndexs addObject:@0];
        [_selectIndexs addObject:@(LFEditToolbarType_draw)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_sticker) {
        [_imageIndexs addObject:@1];
        [_selectIndexs addObject:@(LFEditToolbarType_sticker)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_text) {
        [_imageIndexs addObject:@2];
        [_selectIndexs addObject:@(LFEditToolbarType_text)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_splash) {
        [_imageIndexs addObject:@3];
        [_selectIndexs addObject:@(LFEditToolbarType_splash)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_filter) {
        [_imageIndexs addObject:@7];
        [_selectIndexs addObject:@(LFEditToolbarType_filter)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_crop) {
        [_imageIndexs addObject:@4];
        [_selectIndexs addObject:@(LFEditToolbarType_crop)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_audio) {
        [_imageIndexs addObject:@5];
        [_selectIndexs addObject:@(LFEditToolbarType_audio)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_rate) {
        [_imageIndexs addObject:@8];
        [_selectIndexs addObject:@(LFEditToolbarType_rate)];
        buttonCount ++;
    }
    if (self.type&LFEditToolbarType_clip) {
        [_imageIndexs addObject:@6];
        [_selectIndexs addObject:@(LFEditToolbarType_clip)];
        buttonCount ++;
    }
    
    
    if (buttonCount > 0) {
        CGFloat width = CGRectGetWidth(self.frame)/buttonCount;
        UIFont *font = [UIFont systemFontOfSize:14];
        for (NSInteger i=0; i<buttonCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(width*i, 0, width, kToolbar_MainHeight);
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            button.titleLabel.font = font;
            button.tag = [_selectIndexs[i] integerValue];
            int index = [_imageIndexs[i] intValue];
            [button setImage:bundleEditImageNamed(_mainImageNormals[index]) forState:UIControlStateNormal];
            [button setImage:bundleEditImageNamed(_mainImageHighlighted[index]) forState:UIControlStateHighlighted];
            [button setImage:bundleEditImageNamed(_mainImageHighlighted[index]) forState:UIControlStateSelected];
            [button addTarget:self action:@selector(edit_toolBar_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [edit_menu addSubview:button];
        }
    }
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 40 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.width, 1);
    divide.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    [edit_menu addSubview:divide];
    self.edit_menu = edit_menu;
    
    [self addSubview:edit_menu];
}

- (void)subBar
{
    [self edit_drawMenu];
    [self edit_splashMenu];
    [self edit_rateMenu];
}

#pragma mark - 二级菜单栏(懒加载)
- (UIView *)edit_drawMenu
{
    if (_edit_drawMenu == nil && self.type&LFEditToolbarType_draw) {
        UIView *edit_drawMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.x, _edit_menu.y, _edit_menu.width, kToolbar_SubHeight)];
        edit_drawMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_drawMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_drawMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_drawMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_drawMenu addSubview:button];
        
        UIButton *edit_drawMenu_revoke = [self revokeButtonWithType:LFEditToolbarType_draw];
        [edit_drawMenu addSubview:edit_drawMenu_revoke];
        self.edit_drawMenu_revoke = edit_drawMenu_revoke;
        
        /** 分隔线 */
        UIView *separateView = [self separateView];
        separateView.frame = CGRectMake(CGRectGetMinX(edit_drawMenu_revoke.frame)-2-5, (CGRectGetHeight(edit_drawMenu.frame)-25)/2, 2, 25);
        separateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [edit_drawMenu addSubview:separateView];
        
        CGFloat leftX = 0;
        NSArray *brushImages = EditToolbarBrushImageNormals;
        /** 画笔选择 */
        UIButton *brush = [UIButton buttonWithType:UIButtonTypeCustom];
        brush.frame = CGRectMake(5, 0, 44, kToolbar_SubHeight);
        brush.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [brush setImage:bundleEditImageNamed(brushImages[self.edit_drawMenu_brushType]) forState:UIControlStateNormal];
        [brush addTarget:self action:@selector(brush_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [edit_drawMenu addSubview:brush];
        _edit_drawMenu_brush = brush;
        leftX = CGRectGetMaxX(brush.frame);
        
        /** 颜色显示 */
        CGFloat margin = isiPad ? 85.f : 25.f;
        
        /** 拾色器 */
        CGFloat surplusWidth = CGRectGetMinX(separateView.frame)-2*margin-leftX;
        CGFloat sliderHeight = 34.f, sliderWidth = MIN(surplusWidth, 350);
        JRPickColorView *_colorSlider = [[JRPickColorView alloc] initWithFrame:CGRectMake(leftX + margin + (surplusWidth - sliderWidth) / 2, (CGRectGetHeight(edit_drawMenu.frame)-sliderHeight)/2, sliderWidth, sliderHeight) colors:kSliderColors];
        _colorSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _colorSlider.delegate = self;
        [_colorSlider setMagnifierMaskImage:bundleEditImageNamed(@"EditImageWaterDrop.png")];
        [edit_drawMenu addSubview:_colorSlider];
        self.draw_colorSlider = _colorSlider;
        
        /** 图章类型 */
        UIView *draw_stampView = [[UIView alloc] initWithFrame:_colorSlider.frame];
        NSInteger stampCount = 3;
        CGFloat averageWidth = CGRectGetWidth(draw_stampView.frame)/(stampCount+1);
        NSArray *stampBrushImages = EditToolbarStampBrushImageNormals;
        for (NSInteger i=0; i<stampCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(averageWidth*(i+1)-33/2, (CGRectGetHeight(draw_stampView.frame)-30)/2, 33, 33);
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [button setImage:bundleBrushImageNamed(stampBrushImages[i]) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(drawMenu_stampButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+1;
            if (i == self.edit_drawMenu_stampBrushType) {
                button.selected = YES;
                _edit_drawMenu_action_button = button;
                button.layer.borderColor = kToolbar_SelectedColor.CGColor;
            } else {
                button.layer.borderColor = kToolbar_NormalsColor.CGColor;
            }
            button.layer.borderWidth = 1.0;
            [draw_stampView addSubview:button];
        }
        
        draw_stampView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        draw_stampView.hidden = YES;
        [edit_drawMenu addSubview:draw_stampView];
        self.draw_stampView = draw_stampView;
        
        _edit_drawMenu = edit_drawMenu;
        
        [self insertSubview:edit_drawMenu belowSubview:_edit_menu];
        
    }
    return _edit_drawMenu;
}

- (UIView *)edit_splashMenu
{
    if (_edit_splashMenu == nil && self.type&LFEditToolbarType_splash) {
        UIView *edit_splashMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.x, _edit_menu.y, _edit_menu.width, kToolbar_SubHeight)];
        edit_splashMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_splashMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_splashMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_splashMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_splashMenu addSubview:button];
        
        UIButton *edit_splashMenu_revoke = [self revokeButtonWithType:LFEditToolbarType_splash];
        [edit_splashMenu addSubview:edit_splashMenu_revoke];
        self.edit_splashMenu_revoke = edit_splashMenu_revoke;
        
        /** 分隔线 */
        UIView *separateView = [self separateView];
        separateView.frame = CGRectMake(CGRectGetMinX(edit_splashMenu_revoke.frame)-2-5, (CGRectGetHeight(edit_splashMenu.frame)-25)/2, 2, 25);
        separateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [edit_splashMenu addSubview:separateView];
        
        /** 剩余长度 */
        CGFloat width = CGRectGetMinX(edit_splashMenu_revoke.frame);
        /** 按钮个数 */
        int count = 3;
        /** 平分空间 */
        CGFloat averageWidth = width/(count+1);
        
        NSArray *icons = @[@"EditImageTraditionalMosaicBtn.png", @"EditImageBrushBlurryBtn.png", @"EditImageBrushMosaicBtn.png"];
        NSArray *icons_HL = @[@"EditImageTraditionalMosaicBtn_HL.png", @"EditImageBrushBlurryBtn_HL.png", @"EditImageBrushMosaicBtn_HL.png"];
        
        for (NSInteger i=0; i<count; i++) {
            UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
            action.frame = CGRectMake(averageWidth*(i+1)-44/2, (CGRectGetHeight(edit_splashMenu.frame)-30)/2, 44, 30);
            action.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [action addTarget:self action:@selector(splashMenu_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [action setImage:bundleEditImageNamed(icons[i]) forState:UIControlStateNormal];
            [action setImage:bundleEditImageNamed(icons_HL[i]) forState:UIControlStateHighlighted];
            [action setImage:bundleEditImageNamed(icons_HL[i]) forState:UIControlStateSelected];
            action.tag = i+1;
            [edit_splashMenu addSubview:action];
            
            if (i == 0) {
                /** 优先激活首个按钮 */
                _edit_splashMenu_action_button = action;
                action.selected = YES;
            }
        }
        
        _edit_splashMenu = edit_splashMenu;
        [self insertSubview:edit_splashMenu belowSubview:_edit_menu];
    }
    return _edit_splashMenu;
}

- (UIButton *)revokeButtonWithType:(NSInteger)type
{
    UIButton *revoke = [UIButton buttonWithType:UIButtonTypeCustom];
    revoke.frame = CGRectMake(_edit_menu.width-44-5, 0, 44, kToolbar_SubHeight);
    revoke.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn.png") forState:UIControlStateNormal];
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn_HL.png") forState:UIControlStateHighlighted];
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn_HL.png") forState:UIControlStateSelected];
    revoke.tag = type;
    [revoke addTarget:self action:@selector(revoke_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return revoke;
}

- (UIImageView *)separateView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bundleEditImageNamed(@"AlbumCommentLine.png")];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (UIView *)edit_rateMenu
{
    if (_edit_rateMenu == nil && self.type&LFEditToolbarType_rate) {
        UIView *edit_rateMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.x, _edit_menu.y, _edit_menu.width, kToolbar_SubHeight)];
        edit_rateMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_rateMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_rateMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_rateMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_rateMenu addSubview:button];
        
        /** 间距 */
        CGFloat margin = isiPad ? 85.f : 25.f;
        
        /** 提示label */
        CGFloat labelWidth = 40.f;
        UIButton *tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipsButton.frame = CGRectMake(margin, 0, labelWidth, edit_rateMenu.frame.size.height);
        [tipsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tipsButton setTitle:kToolbar_RateTips(1.0) forState:UIControlStateNormal];
        [tipsButton addTarget:self action:@selector(sliderTipsOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [edit_rateMenu addSubview:tipsButton];
        _edit_rateMenu_tipsButton = tipsButton;
        
        /** slider */
        CGFloat sliderWidth = CGRectGetWidth(edit_rateMenu.frame)-CGRectGetMaxX(tipsButton.frame)-2*margin;
        CGFloat sliderHeight = 34.f;
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tipsButton.frame)+margin, (edit_rateMenu.frame.size.height-sliderHeight)/2, sliderWidth, sliderHeight)];
        slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
//        slider.continuous = NO;
        slider.maximumValue = LFMediaEditMaxRate;
        slider.minimumValue = LFMediaEditMinRate;
        slider.value = 1.0;
        [edit_rateMenu addSubview:slider];
        _edit_rateMenu_slider = slider;
        
        _edit_rateMenu = edit_rateMenu;
        
        [self insertSubview:edit_rateMenu belowSubview:_edit_menu];
    }
    return _edit_rateMenu;
}

- (void)sliderTipsOnClick:(UIButton *)button
{
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(1.0) forState:UIControlStateNormal];
    _edit_rateMenu_slider.value = 1.0;
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:rateDidChange:)]) {
        [self.delegate lf_editToolbar:self rateDidChange:_edit_rateMenu_slider.value];
    }
}

- (void)sliderDidChange:(UISlider *)slider
{
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(slider.value) forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:rateDidChange:)]) {
        float value = [[NSString stringWithFormat:@"%.1f", slider.value] floatValue];
        [self.delegate lf_editToolbar:self rateDidChange:value];
    }
}

#pragma mark - 一级菜单事件(action)
- (void)edit_toolBar_buttonClick:(UIButton *)button
{
    switch (button.tag) {
        case LFEditToolbarType_draw:
        {
            [self showMenuView:self.edit_drawMenu];
            if (button.isSelected == NO) {
                if ([self.delegate respondsToSelector:@selector(lf_editToolbar:canRevokeAtIndex:)]) {
                    BOOL canRevoke = [self.delegate lf_editToolbar:self canRevokeAtIndex:button.tag];
                    _edit_drawMenu_revoke.enabled = canRevoke;
                }
            }
            [self changedButton:button];
        }
            break;
        case LFEditToolbarType_splash:
        {
            [self showMenuView:self.edit_splashMenu];
            if (button.isSelected == NO) {
                if ([self.delegate respondsToSelector:@selector(lf_editToolbar:canRevokeAtIndex:)]) {
                    BOOL canRevoke = [self.delegate lf_editToolbar:self canRevokeAtIndex:button.tag];
                    _edit_splashMenu_revoke.enabled = canRevoke;
                }
            }
            [self changedButton:button];
        }
            break;
        case LFEditToolbarType_rate:
        {
            [self showMenuView:self.edit_rateMenu];
            [self changedButton:button];
        }
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:mainDidSelectAtIndex:)]) {
        [self.delegate lf_editToolbar:self mainDidSelectAtIndex:button.tag];
    }
}

#pragma mark - 二级菜单撤销（action）
- (void)revoke_buttonClick:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:subDidRevokeAtIndex:)]) {
        [self.delegate lf_editToolbar:self subDidRevokeAtIndex:button.tag];
    }
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:canRevokeAtIndex:)]) {
        BOOL canRevoke = [self.delegate lf_editToolbar:self canRevokeAtIndex:button.tag];
        button.enabled = canRevoke;
    }
}

- (void)brush_buttonClick:(UIButton *)button
{
    NSArray *titles = EditToolbarBrushTitles;
    NSArray *normals = EditToolbarBrushImageNormals;
    NSArray *highlighted = EditToolbarBrushImageHighlighted;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    __weak typeof(self) weakSelf = self;
    for (NSInteger i=0; i<titles.count; i++) {
        SPDropItem *item = [[SPDropItem alloc] init];
        item.title = [NSBundle LFME_localizedStringForKey:titles[i]];
        [item setImage:bundleEditImageNamed(normals[i]) forState:SPDropItemStateNormal];
        [item setImage:bundleEditImageNamed(highlighted[i]) forState:SPDropItemStateSelected];
        [item setTitleColor:kToolbar_NormalsColor forState:SPDropItemStateNormal];
        [item setTitleColor:kToolbar_SelectedColor forState:SPDropItemStateSelected];
        if (i == self.edit_drawMenu_brushType) {
            item.selected = YES;
        }
        item.tapHandler = ^(SPDropItem * _Nonnull item) {
//            NSLog(@"onClick %@", item.title);
            weakSelf.edit_drawMenu_brushType = i;
        };
        [items addObject:item];
    }
    [SPDropMenu setDirection:SPDropMainMenuDirectionTop];
    [SPDropMenu showInView:button items:items];
}

- (void)drawMenu_stampButtonClick:(UIButton *)button
{
    if (_edit_drawMenu_action_button != button) {
        _edit_drawMenu_action_button.selected = NO;
        _edit_drawMenu_action_button.layer.borderColor = kToolbar_NormalsColor.CGColor;
        button.selected = YES;
        button.layer.borderColor = kToolbar_SelectedColor.CGColor;
        _edit_drawMenu_action_button = button;
        self.edit_drawMenu_stampBrushType = (EditToolbarStampBrushType)(button.tag-1);
        /** 触发代理 */
        self.edit_drawMenu_brushType = self.edit_drawMenu_brushType;
//        if ([self.delegate respondsToSelector:@selector(lf_editToolbar:subDidSelectAtIndex:)]) {
//            [self.delegate lf_editToolbar:self subDidSelectAtIndex:[NSIndexPath indexPathForRow:button.tag-1 inSection:LFEditToolbarType_draw]];
//        }
    }
}

- (void)splashMenu_buttonClick:(UIButton *)button
{
    if (_edit_splashMenu_action_button != button) {
        _edit_splashMenu_action_button.selected = NO;
        button.selected = YES;
        _edit_splashMenu_action_button = button;
        if ([self.delegate respondsToSelector:@selector(lf_editToolbar:subDidSelectAtIndex:)]) {
            [self.delegate lf_editToolbar:self subDidSelectAtIndex:[NSIndexPath indexPathForRow:button.tag-1 inSection:LFEditToolbarType_splash]];
        }
    }
}

#pragma mark - 显示二级菜单栏
- (void)showMenuView:(UIView *)menu
{
    /** 将显示的菜单先关闭 */
    if (_selectMenu) {
        [self hidenMenuView];
    }
    if (_selectMenu != menu) {
        /** 显示新菜单 */
        _selectMenu = menu;
        [UIView animateWithDuration:0.25f animations:^{
            menu.y = 0;
            menu.alpha = 1.f;
        }];
    } else {
        _selectMenu = nil;
    }
}
- (void)hidenMenuView
{
    [self sendSubviewToBack:_selectMenu];
    [UIView animateWithDuration:0.25f animations:^{
        self->_selectMenu.y = self->_edit_menu.y;
        self->_selectMenu.alpha = 0.f;
    }];
}

#pragma mark - 按钮激活切换
- (BOOL)changedButton:(UIButton *)button
{
    /** 选中按钮 */
    button.selected = !button.selected;
    if (_selectButton != button) {
        _selectButton.selected = !_selectButton.selected;
        _selectButton = button;
    } else {
        _selectButton = nil;
    }
    return (_selectButton != nil);
}

/** 当前激活主菜单 */
- (NSUInteger)mainSelectAtIndex
{
    return _selectButton ? _selectButton.tag : -1;
}

/** 允许撤销 */
- (void)setRevokeAtIndex:(NSUInteger)index
{
    switch (index) {
        case LFEditToolbarType_draw:
        {
            _edit_drawMenu_revoke.enabled = YES;
        }
            break;
        case LFEditToolbarType_splash:
        {
            _edit_splashMenu_revoke.enabled = YES;
        }
            break;
        default:
            break;
    }
}

/** 设置绘画拾色器默认颜色 */
- (void)setDrawSliderColorAtIndex:(NSUInteger)index
{
    self.draw_colorSlider.index = index;
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:drawColorDidChange:)]) {
        [self.delegate lf_editToolbar:self drawColorDidChange:self.draw_colorSlider.color];
    }
}

/** 设置绘画拾色器默认笔刷（会触发代理） */
- (void)setDrawBrushAtIndex:(EditToolbarBrushType)index subIndex:(EditToolbarStampBrushType)subIndex
{
    NSArray *normals = EditToolbarBrushImageNormals;
    if (normals.count > index) {
        _edit_drawMenu_brushType = index;
        if (_edit_drawMenu_stampBrushType != subIndex) {
            /** 模拟点击按钮触发代理 */
            UIButton *button = [self.draw_stampView viewWithTag:(subIndex+1)];
            if (button) {
                _edit_drawMenu_stampBrushType = subIndex;
                [self drawMenu_stampButtonClick:button];
                return;
            }
        }
        /** 触发代理 */
        self.edit_drawMenu_brushType = self.edit_drawMenu_brushType;
    }
}

- (float)rate
{
    return self.edit_rateMenu_slider.value;
}

- (void)setRate:(float)rate
{
    self.edit_rateMenu_slider.value = rate;
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(rate) forState:UIControlStateNormal];
}

- (void)setEdit_drawMenu_brushType:(EditToolbarBrushType)edit_drawMenu_brushType
{
    _edit_drawMenu_brushType = edit_drawMenu_brushType;
    
    // changed view
    BOOL isStamp = (edit_drawMenu_brushType == EditToolbarBrushTypeStamp);
    self.draw_colorSlider.hidden = isStamp;
    self.draw_stampView.hidden = !isStamp;
    
    LFBrush *brush = nil;
    switch (_edit_drawMenu_brushType) {
        case EditToolbarBrushTypePaint:
            brush = [LFPaintBrush new];
            break;
        case EditToolbarBrushTypeHighlight:
            brush = [LFHighlightBrush new];
            break;
        case EditToolbarBrushTypeChalk:
            brush = [LFChalkBrush new];
            break;
        case EditToolbarBrushTypeFluorescent:
            brush = [LFFluorescentBrush new];
            break;
        case EditToolbarBrushTypeStamp:
        {
            switch (self.edit_drawMenu_stampBrushType) {
                case EditToolbarStampBrushTypeAnimal:
                    brush = LFStampBrushAnimal();
                    break;
                case EditToolbarStampBrushTypeFruit:
                    brush = LFStampBrushFruit();
                    break;
                case EditToolbarStampBrushTypeHeart:
                    brush = LFStampBrushHeart();
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    if (brush == nil) {
        /** 超出定制范围，默认使用画笔 */
        self.edit_drawMenu_brushType = EditToolbarBrushTypePaint;
    }
    [self.edit_drawMenu_brush setImage:bundleEditImageNamed(EditToolbarBrushImageNormals[self.edit_drawMenu_brushType]) forState:UIControlStateNormal];
    
    // callback
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:drawBrushDidChange:)]) {
        [self.delegate lf_editToolbar:self drawBrushDidChange:brush];
    }
}

#pragma mark - JRPickColorViewDelegate
- (void)JRPickColorView:(JRPickColorView *)pickColorView didSelectColor:(UIColor *)color
{
    if ([self.delegate respondsToSelector:@selector(lf_editToolbar:drawColorDidChange:)]) {
        [self.delegate lf_editToolbar:self drawColorDidChange:color];
    }
}

#pragma mark - public对外
- (void)selectMainMenuIndex:(NSUInteger)index
{
    UIButton *button = [self.edit_menu viewWithTag:index];
    if ([button isKindOfClass:[UIButton class]]) {
        [self edit_toolBar_buttonClick:button];
    }
}

/** 设置默认模糊类型 */
- (void)setSplashIndex:(NSUInteger)index
{
    UIView *view = [self.edit_splashMenu viewWithTag:index+1];
    if ([view isKindOfClass:[UIButton class]]) {
        [self splashMenu_buttonClick:(UIButton *)view];
    }
}

/** 设置模糊等待状态 */
- (void)setSplashWait:(BOOL)isWait index:(NSUInteger)index
{
    UIView *view = [self.edit_splashMenu viewWithTag:index+1];
    if ([view isKindOfClass:[UIButton class]]) {
        NSInteger tag = 100 + view.tag;
        if (isWait) {
            if ([view.superview viewWithTag:tag]) {
                return;
            }
            UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            aiView.frame = view.frame;
            aiView.tag = tag;
            [aiView startAnimating];
            [view.superview addSubview:aiView];
            view.hidden = YES;
        } else {
            [[view.superview viewWithTag:tag] removeFromSuperview];
            view.hidden = NO;
        }
    }
}

@end
