//
//  LFMovingRemoveView.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2020/10/29.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import "LFMovingRemoveView.h"
#import "UIView+LFMECommon.h"
#import "LFMediaEditingHeader.h"

@interface LFMovingRemoveView ()
/** 内容视图 */
@property (nonatomic, weak) UIView *contentView;
/** 显示的文字 */
@property (nonatomic, weak) UILabel *label;
/** 显示图片 */
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, strong) UIColor *normailColor;
@property (nonatomic, strong) UIColor *selectedColor;

@end

@implementation LFMovingRemoveView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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

- (void)customInit
{
    _normailColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    _selectedColor = [UIColor colorWithRed:218/255.0 green:73/255.0 blue:76/255.0 alpha:1.0];
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:contentView];
    _contentView = contentView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    _imageView = imageView;
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:15.f];
    [self addSubview:label];
    _label = label;
    
    /** 刻意修改，让selected的值改变。 */
    _selected = YES;
    self.selected = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat margin = 10.0;
    [self LFME_setCornerRadius:self.bounds.size.width*0.1];
    self.contentView.frame = self.bounds;
    self.imageView.frame = CGRectMake(margin, margin*2, self.bounds.size.width - margin*2, self.bounds.size.height * 0.6 - margin*3);
    self.label.frame = CGRectMake(margin, self.bounds.size.height * 0.6, self.bounds.size.width - margin*2, self.bounds.size.height * 0.4 - margin);
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        if (selected) {
            self.contentView.backgroundColor = self.selectedColor;
            self.imageView.image = bundleEditImageNamed(@"EditImageStickRemove_HL.png");
            self.label.text = [NSBundle LFME_localizedStringForKey:@"_LFME_sticker_remove_selected"];
        } else {
            self.contentView.backgroundColor = self.normailColor;
            self.imageView.image = bundleEditImageNamed(@"EditImageStickRemove.png");
            self.label.text = [NSBundle LFME_localizedStringForKey:@"_LFME_sticker_remove_normal"];
        }
    }
}

@end
