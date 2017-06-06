//
//  JRPickColorView.m
//  JRSliderToolsView
//
//  Created by 丁嘉睿 on 2017/4/11.
//  Copyright © 2017年 Mr.D. All rights reserved.
//

#import "JRPickColorView.h"


@implementation UIColor (isEqualToColor)

- (BOOL)isEqualToColor:(UIColor *)color{
    return CGColorEqualToColor(self.CGColor, color.CGColor);;
}

@end

CGFloat const JRPickColorView_Default_ColorHeight = 10.0f; //默认颜色高度

CGFloat const JRPickColorView_Default_Height = 40.0f; //默认高度

CGFloat const JRPickColorView_Default_ColorMaxWidth = 15.0f; // 默认最大宽度

CGFloat const JRPickColorView_Default_ColorMinWidth = 10.0f; // 默认最小宽度


@interface JRPickColorView () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIView *showColorsContainer; //!@滑块显示颜色视图

@property (assign, nonatomic) CGFloat colorWidth; //!@区域长度
/** 水平还是垂直，默认水平 */
@property (assign, nonatomic) BOOL showHorizontal;

@property (assign, nonatomic) CGPoint initialPoint;

@end

@implementation JRPickColorView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _animation = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *>*)colors{
    self = [self initWithFrame:frame];
    if (self) {
        [self setColors:colors];
    }return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_showHorizontal) {
        _colorWidth = CGRectGetWidth(self.frame) / self.colors.count;
    }
}

#pragma mark - setter
- (void)setShowHorizontal:(BOOL)showHorizontal{
    CGRect rect = self.frame;
    _showHorizontal = showHorizontal;
//    if (showHorizontal) {
//        if (rect.size.width < rect.size.height) {
//            rect.size.width = rect.size.height;
//        }
//        rect.size.height = JRPickColorView_Default_Height;
        _colorWidth = rect.size.width / self.colors.count;
//    } else {
//        if (rect.size.width > rect.size.height) {
//            rect.size.height = rect.size.width;
//        }
//        rect.size.width = JRPickColorView_Default_Height;
//        _colorWidth = rect.size.height / _currentColors.count;
//    }
//    self.frame = rect;
    //第一个参数是条件,如果第一个参数不满足条件,就会记录并打印后面的字符串
    BOOL isCreate = _colorWidth <= JRPickColorView_Default_ColorMinWidth;
    if (!isCreate) {
        [self createShowColorsContainer];
    } else {
        NSCAssert(!isCreate, @"💩💩💩请给足够宽度显示选择器！！！💩💩💩");   
    }
}

#pragma mark 当前颜色数组下标
- (void)setIndex:(NSUInteger)index{
    if (index > self.colors.count) index = 0;
    _index = index;
    [self setColor:[self.colors objectAtIndex:index]];
}

#pragma mark 当前选择颜色
- (void)setColor:(UIColor *)color{
    NSInteger currentIndex = 0;
    BOOL isYES = NO;
    for (NSInteger i=0; i<self.colors.count; i++) {
        UIColor *color1 = self.colors[i];
        if ([color isEqualToColor:color1]) {
            currentIndex = i;
            isYES = YES;
            break;
        }
    }
    _color = isYES ? color : [self.colors firstObject];
    _index = currentIndex;
    _showColorsContainer.backgroundColor = _color;
    CGPoint point = _showColorsContainer.center;
    point.x = currentIndex * _colorWidth + _colorWidth / 2;
    _showColorsContainer.center = point;
}
#pragma mark 设置颜色数组
- (void)setColors:(NSArray<UIColor *> *)colors{
    _color = [colors firstObject];
    _colors = colors;
    [self commUI];
}

- (void)drawRect:(CGRect)rect{
    [self createRectangleView];
}
#pragma mark - Private Methods
#pragma mark 初始化控件
- (void)commUI{
    [self setShowHorizontal:YES];
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark 返回根据位置计算所在区域以及颜色
- (void)calu:(NSInteger)gestureRecognizer point:(CGPoint)point comple:(void(^)(UIColor *color, CGPoint center))comple{
    CGFloat x = point.x;
    /** 最小中心点 */
    CGFloat Mid = CGRectGetWidth(_showColorsContainer.frame) / 2;
    /** 限制滑动范围 */
    if (x <= CGRectGetWidth(self.frame) && x >= (CGRectGetWidth(self.frame) - CGRectGetWidth(_showColorsContainer.frame))) 
    {
        x = CGRectGetWidth(self.frame) - Mid;
    }
    if (x > CGRectGetWidth(self.frame)){
        x = CGRectGetWidth(self.frame) - Mid;
    }
    if (x < Mid) {
        x = Mid;
    }
    point.x = x;
    _index = x / _colorWidth;
    point.y = CGRectGetMidY(_showColorsContainer.frame);
    UIColor *changeColor = self.colors[_index];
    _color = changeColor;
    if (self.pickColorEndBlock) self.pickColorEndBlock(changeColor);
    if ([self.delegate respondsToSelector:@selector(JRPickColorView:didSelectColor:)]) {
        [self.delegate JRPickColorView:self didSelectColor:changeColor];
    }
    if (comple) comple(_color, point);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == _showColorsContainer) {
        return self;
    }
    return view;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    /** 拦截点击事件 */
    return NO;
}

#pragma mark 点击手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _initialPoint = [touch locationInView:self];//开始触摸
    __weak typeof(self)weakSelf = self;
    [self calu:0 point:_initialPoint comple:^(UIColor *color, CGPoint center) {
        weakSelf.showColorsContainer.backgroundColor = color;
        weakSelf.showColorsContainer.center = center;
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startAnimation];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startAnimation];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];//开始触摸
    __weak typeof(self)weakSelf = self;
    [self calu:0 point:p comple:^(UIColor *color, CGPoint center) {
        weakSelf.showColorsContainer.backgroundColor = color;
        weakSelf.showColorsContainer.center = center;
    }];
}


#pragma mark 动画
//让滑块位于图片区域中心位置，回调也在这里
- (void)startAnimation{
    CGFloat x = _index * _colorWidth + (_colorWidth / 2);
    if (self.animation) {
        [UIView animateWithDuration:0.25f delay:0.f usingSpringWithDamping:1.0f initialSpringVelocity:0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGPoint point = _showColorsContainer.center;
            point.x = x;
            _showColorsContainer.center = point;
        } completion:nil];
    } else {
        CGPoint point = _showColorsContainer.center;
        point.x = x;
        _showColorsContainer.center = point;
    }
}
#pragma mark 创建展示颜色容器
- (void)createShowColorsContainer{
    CGFloat showColorsContainerW = _colorWidth / 2;
    showColorsContainerW = MAX(showColorsContainerW, JRPickColorView_Default_ColorMinWidth);
    showColorsContainerW = MIN(showColorsContainerW, JRPickColorView_Default_ColorMaxWidth);
    CGRect rect = CGRectMake((_colorWidth - showColorsContainerW) / 2, (CGRectGetHeight(self.frame) - JRPickColorView_Default_ColorHeight * 2.5)/2, showColorsContainerW, JRPickColorView_Default_ColorHeight * 2.5);
    if (!_showColorsContainer) {
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        view.backgroundColor = [self.colors firstObject];
        view.layer.cornerRadius = CGRectGetWidth(rect)/2;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1.0f;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        _showColorsContainer = view;
        [self addSubview:_showColorsContainer];
    } else {
        _showColorsContainer.frame = rect;
    }
}
#pragma mark 创建段位
- (void)createRectangleView{
    for (NSInteger i = 0; i < self.colors.count; i ++) {
        CGFloat x = i * _colorWidth;
        CGRect rect = CGRectMake(x, (CGRectGetHeight(self.frame) - JRPickColorView_Default_ColorHeight)/2, _colorWidth, JRPickColorView_Default_ColorHeight);
        NSInteger line = 4;
        if (i == 0) {
            line = 1;
        } else if (i == self.colors.count - 1) {
            line = 3;
        }
        if (!_showHorizontal) {
            if (i == 0) {
                line = 0;
            } else if (i == self.colors.count - 1) {
                line = 2;
            }
//            rect = CGRectMake(JRPickColorView_Default_ColorY, x, JRPickColorView_Default_ColorHeight, _colorWidth);
        }
        CGFloat cornerRadius = JRPickColorView_Default_ColorHeight / 2;
        [self drawWithRect:rect color:[self.colors objectAtIndex:i] line:line cornerRadius:cornerRadius];
    }
}

#pragma mark 画矩形

/**
 画矩形

 @param rect rect
 @param color 填充颜色
 @param line 是否需要圆角(0/1/2/3:上左下右画半圆 其它的都是矩形)
 */
- (void)drawWithRect:(CGRect)rect color:(UIColor *)color line:(NSInteger)line cornerRadius:(CGFloat)cornerRadius{
    // 1取得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 填充颜色
    [color set];
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    if (line == 0) {//上
        /** 起始坐标 */
        CGContextMoveToPoint(ctx, x, cornerRadius);  
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x, y + height);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, y + height);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x + width, y, (x + width)/2, y, cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x, y, x, cornerRadius, cornerRadius);
    } else if (line == 1) {//左
        /** 起始坐标 */
        CGContextMoveToPoint(ctx, x + cornerRadius, y);  
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, y);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, y + height);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + cornerRadius, y + height);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x, y + height, x, (y + height)/2, cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x, y, x + cornerRadius, y, cornerRadius);
    } else if (line == 2) {//下
        /** 起始坐标 */
        CGContextMoveToPoint(ctx, x, y + height - cornerRadius);  
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x, y);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, y);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width, y + height - cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x + width, y + height, (x + width)/2, y + height, cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x, y + height, x, y + height - cornerRadius, cornerRadius);
    } else if (line == 3) {//右
        /** 起始坐标 */
        CGContextMoveToPoint(ctx, x - cornerRadius, y);  
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x, y);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x, y + height);
        /** 画条直线 */
        CGContextAddLineToPoint(ctx, x + width - cornerRadius, y + height);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x + width, y + height, x + width, (y + height)/2, cornerRadius);
        /** 画1/4圆 */
        CGContextAddArcToPoint(ctx, x + width, y, x + width - cornerRadius, y, cornerRadius);
    } else {
        CGContextFillRect(ctx, rect);
    }
    // 3渲染
    CGContextFillPath(ctx);
}

@end


