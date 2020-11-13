//
//  LFTextBar.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFTextBar.h"
#import "UIView+LFMEFrame.h"
#import "LFMediaEditingHeader.h"
#import "LFStickerItem.h"
#import "JRPickColorView.h"
#import "LFTextViewBackgroundLayoutManager.h"

/** 来限制最大输入只能150个字符 */
#define MAX_LIMIT_NUMS 150

CGFloat const LFTextBarFontBGTag = 220;
CGFloat const LFTextBarAlignmentTag = 221;

@interface LFTextBar () <UITextViewDelegate, JRPickColorViewDelegate>

@property (nonatomic, weak) UIView *topbar;
@property (nonatomic, weak) UITextView *lf_textView;
@property (nonatomic, strong) LFTextViewBackgroundLayoutManager *layoutManager;

@property (nonatomic, weak) JRPickColorView *lf_colorSlider;
@property (nonatomic, weak) UIView *lf_keyboardBar;



@end

@implementation LFTextBar

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
    return [self initWithFrame:frame layout:nil];
}

- (instancetype)initWithFrame:(CGRect)frame layout:(void (^)(LFTextBar *textBar))layoutBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        _customTopbarHeight = 64.f;
        _naviHeight = 44.f;
        if (layoutBlock) {
            layoutBlock(self);
        }
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _maxLimitCount = MAX_LIMIT_NUMS;
    if (@available(iOS 8.0, *)) {
        // 定义毛玻璃效果
        self.backgroundColor = [UIColor clearColor];
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
        effe.frame = self.bounds;
        effe.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        effe.alpha = 0.8;
        [self addSubview:effe];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    
    [self addKeyBoardNotify];
    
    [self configCustomNaviBar];
    [self configTextView];
    [self configKeyBoardBar];

    [self setTextSliderColorAtIndex:0]; /** 白色 */
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.lf_textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.lf_textView resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addKeyBoardNotify
{
    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setShowText:(LFText *)showText
{
    _showText = showText;
    if (showText.attributedText.length > 0) {
        self.layoutManager.layoutData = showText.layoutData;
        [self.lf_textView setAttributedText:showText.attributedText];
        UIColor *textColor = self.layoutManager.type == LFCGContextDrawTextBackgroundTypeNone ? self.lf_textView.textColor : self.layoutManager.usedColor;
        [self setTextSliderColor:textColor];
    }
    UIView *alignmentView = [self.lf_keyboardBar viewWithTag:LFTextBarAlignmentTag];
    for (UIButton *btn in alignmentView.subviews) {
        btn.selected = (btn.tag == self.lf_textView.textAlignment);
    }
    UIButton *fontBGButton = [self.lf_keyboardBar viewWithTag:LFTextBarFontBGTag];
    fontBGButton.selected = !(self.layoutManager.type == LFCGContextDrawTextBackgroundTypeNone);
}

- (void)configCustomNaviBar
{
    /** 顶部栏 */
    CGFloat margin = 8;
    CGFloat size = _naviHeight;
    
    CGFloat topbarHeight = _customTopbarHeight;
    CGFloat topSubViewY = topbarHeight - size;
    
    UIView *topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.lfme_width, topbarHeight)];
    topbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    topbar.backgroundColor = [UIColor clearColor];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [self.cancelButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _customTopbarHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, topSubViewY, editCancelWidth, size)];
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = font;
    [cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat editOkWidth = [self.oKButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _customTopbarHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.lfme_width - editOkWidth - margin, topSubViewY, editOkWidth, size)];
    finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [finishButton setTitle:self.oKButtonTitle forState:UIControlStateNormal];
    finishButton.titleLabel.font = font;
    [finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [topbar addSubview:cancelButton];
    [topbar addSubview:finishButton];
    
    [self addSubview:topbar];
    _topbar = topbar;
}

- (void)configTextView
{
    NSTextStorage *storage = [NSTextStorage new];
    self.layoutManager = [LFTextViewBackgroundLayoutManager new];
    [storage addLayoutManager:self.layoutManager];
    
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    [self.layoutManager addTextContainer:container];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_topbar.frame), self.lfme_width, self.lfme_height-CGRectGetHeight(_topbar.frame)) textContainer:container];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    textView.delegate = self;
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    [textView setFont:[UIFont systemFontOfSize:35.f]];
    CGFloat xMargin = 8, yMargin = 8;
    // 使用textContainerInset设置top、leaft、right
    textView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, yMargin, xMargin);
    textView.layoutManager.allowsNonContiguousLayout = NO;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.f;
    NSDictionary *attributes = @{
        NSFontAttributeName:textView.font,
        NSParagraphStyleAttributeName:style
    };
    textView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    
    //UITextInputTraits
    textView.returnKeyType = UIReturnKeyDefault;
    textView.spellCheckingType = UITextSpellCheckingTypeNo;
    [self addSubview:textView];
    self.lf_textView = textView;
}

- (void)configKeyBoardBar
{
    CGFloat margin = isiPad ? 40.f : 10.f;
    UIView *keyboardBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.lfme_height-margin, self.lfme_width, 44)];
    keyboardBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    keyboardBar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    
    CGFloat maxSliderWidth = CGRectGetWidth(keyboardBar.frame);
    CGFloat sliderX = 0;
    /**
     字体
     */
    if (/* DISABLES CODE */ (NO)) {
        UIButton *font = [UIButton buttonWithType:UIButtonTypeCustom];
        font.frame = CGRectMake(CGRectGetWidth(keyboardBar.frame)-44-5, 0, 44, CGRectGetHeight(keyboardBar.frame));
        [font setImage:bundleEditImageNamed(@"EditImageTextFont.png") forState:UIControlStateNormal];
        [font setImage:bundleEditImageNamed(@"EditImageTextFont_HL.png") forState:UIControlStateHighlighted];
        [font setImage:bundleEditImageNamed(@"EditImageTextFont_HL.png") forState:UIControlStateSelected];
        [font addTarget:self action:@selector(font_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [keyboardBar addSubview:font];
        
        maxSliderWidth = CGRectGetMinX(font.frame);
    }
    
    /**
     对齐方式
     */
    {
        NSInteger count = 3;
        CGFloat width = 42, margin = isiPad ? 5 : 0;
        CGFloat maxWidth = width*count + margin*(count+1);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(maxSliderWidth-maxWidth, 0, maxWidth, 44)];
        view.backgroundColor = [UIColor clearColor];
        view.tag = LFTextBarAlignmentTag;
        
        UIButton * (^createButtonWithIndex)(NSInteger) = ^UIButton * (NSInteger index){
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(margin*(index+1)+index*width, (CGRectGetHeight(view.frame)-width)/2, width, width);
            button.tag = index;
            NSString *name = nil, *highlightName = nil;;
            switch (index) {
                case 0: //left
                {
                    name = @"EditImageTextAlignmentLeft.png";
                    highlightName = @"EditImageTextAlignmentLeft_HL.png";
                }
                    break;
                case 1: //center
                {
                    name = @"EditImageTextAlignmentCenter.png";
                    highlightName = @"EditImageTextAlignmentCenter_HL.png";
                }
                    break;
                case 2: //right
                {
                    name = @"EditImageTextAlignmentRight.png";
                    highlightName = @"EditImageTextAlignmentRight_HL.png";
                }
                    break;
                default:
                    return nil;
            }
            [button setImage:bundleEditImageNamed(name) forState:UIControlStateNormal];
            [button setImage:bundleEditImageNamed(highlightName) forState:UIControlStateHighlighted];
            [button setImage:bundleEditImageNamed(highlightName) forState:UIControlStateSelected];
            [button addTarget:self action:@selector(alignment_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            return button;
        };
        
        for (NSInteger i = 0; i < count; i++) {
            UIButton *button = createButtonWithIndex(i);
            if (button) {
                [view addSubview:button];
            }
            if (i == 0) {
                button.selected = YES;
            }
        }
        [keyboardBar addSubview:view];
        
        maxSliderWidth = CGRectGetMinX(view.frame);
    }
    
    UIButton *fontBG = [UIButton buttonWithType:UIButtonTypeCustom];
    fontBG.frame = CGRectMake(5, 0, 44, CGRectGetHeight(keyboardBar.frame));
    fontBG.tag = LFTextBarFontBGTag;
    [fontBG setImage:bundleEditImageNamed(@"EditImageTextBG.png") forState:UIControlStateNormal];
    [fontBG setImage:bundleEditImageNamed(@"EditImageTextBG_HL.png") forState:UIControlStateHighlighted];
    [fontBG setImage:bundleEditImageNamed(@"EditImageTextBG_HL.png") forState:UIControlStateSelected];
    [fontBG addTarget:self action:@selector(fontBG_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [keyboardBar addSubview:fontBG];
    
    sliderX = CGRectGetMaxX(fontBG.frame);
    maxSliderWidth -= CGRectGetWidth(fontBG.frame) + 5;
    
    /** 拾色器 */
    CGFloat sliderHeight = 34.f;
    CGFloat sliderWidth = MIN(380, maxSliderWidth-2*margin);
    JRPickColorView *_colorSlider = [[JRPickColorView alloc] initWithFrame:CGRectMake(sliderX + (maxSliderWidth-sliderWidth)/2, (CGRectGetHeight(keyboardBar.frame)-sliderHeight)/2, sliderWidth, sliderHeight) colors:kSliderColors];
//    _colorSlider.showColor = kSliderColors[0]; /** 白色 */
    _colorSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _colorSlider.delegate = self;
    [_colorSlider setMagnifierMaskImage:bundleEditImageNamed(@"EditImageWaterDrop.png")];
    [keyboardBar addSubview:_colorSlider];
    self.lf_colorSlider = _colorSlider;
    
    [self addSubview:keyboardBar];
    self.lf_keyboardBar = keyboardBar;
}

/** 设置文字拾起器默认颜色 */
- (void)setTextColor:(UIColor *)textColor
{
    if (self.layoutManager.type == LFCGContextDrawTextBackgroundTypeNone) {
        self.lf_textView.textColor = textColor;
        self.layoutManager.usedColor = textColor;
    } else {
        self.lf_textView.textColor = [textColor isEqual:[UIColor whiteColor]] ? [UIColor blackColor] : [UIColor whiteColor];
        self.layoutManager.usedColor = textColor;
    }
}

/** 设置文本拾色器默认颜色 */
- (void)setTextSliderColor:(UIColor *)color
{
    self.lf_colorSlider.color = color;
    [self setTextColor:self.lf_colorSlider.color];
}

- (void)setTextSliderColorAtIndex:(NSUInteger)index
{
    self.lf_colorSlider.index = index;
    [self setTextColor:self.lf_colorSlider.color];
}

#pragma mark - button action
- (void)alignment_buttonClick:(UIButton *)button
{
    UIView *alignmentView = [self.lf_keyboardBar viewWithTag:LFTextBarAlignmentTag];
    for (UIButton *btn in alignmentView.subviews) {
        btn.selected = (btn == button);
    }
    self.lf_textView.textAlignment = (NSTextAlignment)button.tag;
    if (self.layoutManager.type != LFCGContextDrawTextBackgroundTypeNone) {
        /** 需要重新填充颜色进行绘制背景。解决补位情况绘制会出现偏差。 */
        [self setTextColor:self.lf_colorSlider.color];
    }
    
}
- (void)font_buttonClick:(UIButton *)button
{
    NSLog(@"正在完善...");
}
- (void)fontBG_buttonClick:(UIButton *)button
{
    button.selected = !button.isSelected;
    
    if (button.isSelected) {
        self.layoutManager.type = LFCGContextDrawTextBackgroundTypeSolid;
    } else {
        self.layoutManager.type = LFCGContextDrawTextBackgroundTypeNone;
    }
    [self setTextColor:self.lf_colorSlider.color];
}

#pragma mark - 顶部栏(action)
- (void)cancelButtonClick
{
    if ([self.delegate respondsToSelector:@selector(lf_textBarControllerDidCancel:)]) {
        [self.delegate lf_textBarControllerDidCancel:self];
    }
}

- (void)finishButtonClick
{
    if ([self.delegate respondsToSelector:@selector(lf_textBarController:didFinishText:)]) {
        LFText *text = nil;
        if (self.lf_textView.text.length) {            
            text = [LFText new];
//            text.text = self.lf_textView.text;
//            text.textColor = self.lf_textView.textColor;
//            text.font = self.lf_textView.font;
            text.attributedText = self.lf_textView.attributedText;
            text.layoutData = self.layoutManager.layoutData;
            text.usedRect = [self.layoutManager usedRectForTextContainer:self.lf_textView.textContainer];
        }
        [self.delegate lf_textBarController:self didFinishText:text];
    }
}

#pragma mark - 键盘通知出来方法
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.lf_keyboardBar.lfme_y = self.lfme_height-CGRectGetHeight(keyboardRect)-CGRectGetHeight(self.lf_keyboardBar.frame);
        self.lf_textView.lfme_height = self.lfme_height-self.lf_keyboardBar.lfme_y;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.lf_keyboardBar.lfme_y = self.lfme_height-CGRectGetHeight(keyboardRect)-CGRectGetHeight(self.lf_keyboardBar.frame);
        self.lf_textView.lfme_height = self.lfme_height-self.lf_keyboardBar.lfme_y;
    }];
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
//    if ([text isEqualToString:@"\n"])
//    {
//        [self finishButtonClick];
//        return NO;
//    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < _maxLimitCount) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    // 回车的限制
//    NSString *searchString = @"\n";
    NSInteger canInputEnter = 0;//_maxLimitCount/10 - ([comcatstr length] - [[comcatstr stringByReplacingOccurrencesOfString:searchString withString:@""] length]) / [searchString length];
    
    NSInteger caninputlen = _maxLimitCount - comcatstr.length;
    
    if (caninputlen >= 0 && canInputEnter >= 0)
    {
        return YES;
    }
    else
    {
        if (caninputlen < 0) {
            NSInteger len = text.length + caninputlen;
            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            NSRange rg = {0,MAX(len,0)};
            
            if (rg.length > 0)
            {
                NSString *s = @"";
                //判断是否只普通的字符或asc码(对于中文和表情返回NO)
                BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
                if (asc) {
                    s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
                }
                else
                {
                    __block NSInteger idx = 0;
                    __block NSString  *trimString = @"";//截取出的字串
                    //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                             options:NSStringEnumerationByComposedCharacterSequences
                                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                              
                                              if (idx >= rg.length) {
                                                  *stop = YES; //取出所需要就break，提高效率
                                                  return ;
                                              }
                                              
                                              trimString = [trimString stringByAppendingString:substring];
                                              
                                              idx++;
                                          }];
                    
                    s = trimString;
                }
                //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
                [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
                //既然是超出部分截取了，哪一定是最大限制了。
                //            self.lbNums.text = [NSString stringWithFormat:@"%d/%ld",0,(long)_maxLimitCount];
            }
        }
        if ([self.delegate respondsToSelector:@selector(lf_textBarControllerDidReachMaximumLimit:)]) {
            [self.delegate lf_textBarControllerDidReachMaximumLimit:self];
        }
        return NO;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.layoutManager.type != LFCGContextDrawTextBackgroundTypeNone) {
        /** 需要重新填充颜色进行绘制背景。解决补位情况绘制会出现偏差。 */
        [self setTextColor:self.lf_colorSlider.color];
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        if (selectedRange && position) {
            return;
        }
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            if(toBeString.length > _maxLimitCount) {
                //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
                textView.text = [toBeString substringToIndex:_maxLimitCount];
            }
        }
    } else{ //中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if(toBeString.length > _maxLimitCount) {
            
            //防止表情被截段
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:_maxLimitCount];
            textView.text = [toBeString substringToIndex:(rangeIndex.location)];
        }
    }
    
    
    //不让显示负数 口口日
//    self.lbNums.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,_maxLimitCount - existTextNum),_maxLimitCount];
}

#pragma mark - JRPickColorViewDelegate
- (void)JRPickColorView:(JRPickColorView *)pickColorView didSelectColor:(UIColor *)color
{
    [self setTextColor:color];
}
@end
