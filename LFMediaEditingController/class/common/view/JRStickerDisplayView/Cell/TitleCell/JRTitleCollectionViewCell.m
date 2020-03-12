//
//  JRTitleCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRTitleCollectionViewCell.h"
#import "JRConfigTool.h"
#import "UIColor+TransformColor.h"
#import "JRCollectionViewTitleModel.h"

@interface JRTitleCollectionViewCell ()

@property (weak, nonatomic) UILabel *label;

@end

@implementation JRTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _createCustomView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = nil;
}


- (void)setCellData:(id)data
{
    [super setCellData:data];
    if ([data isKindOfClass:[JRCollectionViewTitleModel class]]) {
        JRCollectionViewTitleModel *model = (JRCollectionViewTitleModel *)data;
        self.label.text = model.title;
        self.label.font = model.font;
    }
}

- (void)showAnimationOfProgress:(CGFloat)progress select:(BOOL)select
{
    if (select) {
        self.label.textColor = [UIColor colorTransformFrom:[JRConfigTool shareInstance].normalTitleColor to:[JRConfigTool shareInstance].selectTitleColor progress:progress];
    } else {
        self.label.textColor = [UIColor colorTransformFrom:[JRConfigTool shareInstance].selectTitleColor to:[JRConfigTool shareInstance].normalTitleColor progress:progress];
    }
}

#pragma mark - Private Methods
- (void)_createCustomView
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:lable];
    self.label = lable;
    self.label.numberOfLines = 1.f;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
}



@end
