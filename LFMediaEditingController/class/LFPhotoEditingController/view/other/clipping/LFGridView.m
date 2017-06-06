//
//  LFGridView.m
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFGridView.h"
#import "LFGridLayer.h"
#import "LFGridMaskLayer.h"
#import "LFResizeControl.h"

/** 可控范围 */
const CGFloat kControlWidth = 30.f;

@interface LFGridView () <lf_resizeConrolDelegate>

@property (nonatomic, weak) LFResizeControl *topLeftCornerView;
@property (nonatomic, weak) LFResizeControl *topRightCornerView;
@property (nonatomic, weak) LFResizeControl *bottomLeftCornerView;
@property (nonatomic, weak) LFResizeControl *bottomRightCornerView;
@property (nonatomic, weak) LFResizeControl *topEdgeView;
@property (nonatomic, weak) LFResizeControl *leftEdgeView;
@property (nonatomic, weak) LFResizeControl *bottomEdgeView;
@property (nonatomic, weak) LFResizeControl *rightEdgeView;

@property (nonatomic, weak) LFGridMaskLayer *gridMaskLayer;

@property (nonatomic, assign) CGRect initialRect;

@property (nonatomic, weak) LFGridLayer *gridLayer;

@end

@implementation LFGridView

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
    /** 遮罩 */
    LFGridMaskLayer *gridMaskLayer = [[LFGridMaskLayer alloc] init];
    gridMaskLayer.frame = self.bounds;
    gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:.5f].CGColor;
    [self.layer addSublayer:gridMaskLayer];
    self.gridMaskLayer = gridMaskLayer;
    
    /** 宫格 */
    LFGridLayer *gridLayer = [[LFGridLayer alloc] init];
    gridLayer.frame = self.bounds;
    gridLayer.lineWidth = 2.f;
    gridLayer.bgColor = [UIColor clearColor];
    gridLayer.gridColor = [UIColor whiteColor];
    [self.layer addSublayer:gridLayer];
    self.gridLayer = gridLayer;
    
    self.gridRect = CGRectInset(self.bounds, 50, 50);
    self.controlMinSize = CGSizeMake(80, 80);
    self.controlMaxRect = CGRectInset(self.bounds, 50, 50);
    /** 遮罩范围 */
    self.showMaskLayer = YES;
    
    self.topLeftCornerView = [self createResizeControl];
    self.topRightCornerView = [self createResizeControl];
    self.bottomLeftCornerView = [self createResizeControl];
    self.bottomRightCornerView = [self createResizeControl];
    
    self.topEdgeView = [self createResizeControl];
    self.leftEdgeView = [self createResizeControl];
    self.bottomEdgeView = [self createResizeControl];
    self.rightEdgeView = [self createResizeControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gridLayer.frame = self.bounds;
    self.gridMaskLayer.frame = self.bounds;
    
    CGRect rect = self.gridRect;
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.topLeftCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topLeftCornerView.bounds) / 2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topRightCornerView.bounds) / 2, self.topRightCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.bottomLeftCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetMinY(rect) - CGRectGetHeight(self.topEdgeView.frame) / 2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.leftEdgeView.frame) / 2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
}

- (void)setShowMaskLayer:(BOOL)showMaskLayer
{
    if (_showMaskLayer != showMaskLayer) {
        _showMaskLayer = showMaskLayer;
        if (showMaskLayer) {
            /** 还原遮罩 */
            self.gridMaskLayer.maskRect = self.gridRect;
        } else {
            /** 扩大遮罩范围 */
            self.gridMaskLayer.maskRect = self.gridMaskLayer.bounds;
        }
    }
    /** 简单粗暴的禁用拖动事件 */
    self.userInteractionEnabled = showMaskLayer;
}

#pragma mark - lf_resizeConrolDelegate

- (void)lf_resizeConrolDidBeginResizing:(LFResizeControl *)resizeConrol
{
    self.initialRect = self.gridRect;
    
//    self.showMaskLayer = NO;
    if ([self.delegate respondsToSelector:@selector(lf_gridViewDidBeginResizing:)]) {
        [self.delegate lf_gridViewDidBeginResizing:self];
    }
}
- (void)lf_resizeConrolDidResizing:(LFResizeControl *)resizeConrol
{
    CGRect gridRect = [self cropRectMakeWithResizeControlView:resizeConrol];
    [self setGridRect:gridRect maskLayer:NO];
    
    if ([self.delegate respondsToSelector:@selector(lf_gridViewDidResizing:)]) {
        [self.delegate lf_gridViewDidResizing:self];
    }
}
- (void)lf_resizeConrolDidEndResizing:(LFResizeControl *)resizeConrol
{
//    self.showMaskLayer = YES;
    if ([self.delegate respondsToSelector:@selector(lf_gridViewDidEndResizing:)]) {
        [self.delegate lf_gridViewDidEndResizing:self];
    }
}

#pragma mark - private
- (void)setGridRect:(CGRect)gridRect
{
    [self setGridRect:gridRect maskLayer:YES];
}
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer
{
    [self setGridRect:gridRect maskLayer:isMaskLayer animated:NO];
}
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated
{
    [self setGridRect:gridRect maskLayer:NO animated:animated];
}
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated
{
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        [self.gridLayer setGridRect:gridRect animated:animated];
        if (isMaskLayer) {
            self.gridMaskLayer.maskRect = gridRect;
        }
        [self setNeedsLayout];
    }
}

- (LFResizeControl *)createResizeControl
{
    LFResizeControl *control = [[LFResizeControl alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(kControlWidth, kControlWidth)}];
    control.delegate = self;
    [self addSubview:control];
    return control;
}

- (CGRect)cropRectMakeWithResizeControlView:(LFResizeControl *)resizeControlView
{
    CGRect rect = self.gridRect;
    
    if (resizeControlView == self.topEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.leftEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    } else if (resizeControlView == self.bottomEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
    } else if (resizeControlView == self.rightEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    } else if (resizeControlView == self.topLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.topRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.bottomLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
    } else if (resizeControlView == self.bottomRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
    }
    
    /** ps：
        此处判断 不能使用CGRectGet开头的方法，计算会有问题；
        当rect = (origin = (x = 50, y = 618), size = (width = 61, height = -488)) 时，
        CGRectGetMaxY(rect) = 618；CGRectGetHeight(rect) = 488
     */
    
    /** 限制x/y 超出左上角 最大限度 */
    if (ceil(rect.origin.x) < ceil(CGRectGetMinX(_controlMaxRect))) {
        rect.origin.x = _controlMaxRect.origin.x;
        rect.size.width = CGRectGetMaxX(self.initialRect)-rect.origin.x;
    }
    if (ceil(rect.origin.y) < ceil(CGRectGetMinY(_controlMaxRect))) {
        rect.origin.y = _controlMaxRect.origin.y;
        rect.size.height = CGRectGetMaxY(self.initialRect)-rect.origin.y;
    }
    
    /** 限制宽度／高度 超出 最大限度 */
    if (ceil(rect.origin.x+rect.size.width) > ceil(CGRectGetMaxX(_controlMaxRect))) {
        rect.size.width = CGRectGetMaxX(_controlMaxRect) - CGRectGetMinX(rect);
    }
    if (ceil(rect.origin.y+rect.size.height) > ceil(CGRectGetMaxY(_controlMaxRect))) {
        rect.size.height = CGRectGetMaxY(_controlMaxRect) - CGRectGetMinY(rect);
    }
    
    /** 限制宽度／高度 小于 最小限度 */
    if (ceil(rect.size.width) < ceil(_controlMinSize.width)) {
        /** 左上、左、左下 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.leftEdgeView || resizeControlView == self.bottomLeftCornerView) {
            rect.origin.x = CGRectGetMaxX(self.initialRect) - _controlMinSize.width;
        }
        rect.size.width = _controlMinSize.width;
    }
    if (ceil(rect.size.height) < ceil(_controlMinSize.height)) {
        /** 左上、上、右上 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.topEdgeView || resizeControlView == self.topRightCornerView) {
            rect.origin.y = CGRectGetMaxY(self.initialRect) - _controlMinSize.height;
        }
        rect.size.height = _controlMinSize.height;
    }
    
    return rect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view) {
        return nil;
    }
    return view;
}

@end
