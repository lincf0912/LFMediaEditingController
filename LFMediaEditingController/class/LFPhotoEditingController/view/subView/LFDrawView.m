//
//  LFDrawView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFDrawView.h"

inline static CGPoint LFDrawMidPoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

NSString *const kLFDrawViewData = @"LFDrawViewData";

@interface LFDrawBezierPath : UIBezierPath

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGPoint previousPoint;

@end

@implementation LFDrawBezierPath


@end



@interface LFDrawView ()
{
    BOOL _isWork;
    BOOL _isBegan;
}
/** 笔画 */
@property (nonatomic, strong) NSMutableArray <LFDrawBezierPath *>*lineArray;
/** 图层 */
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*slayerArray;

@end

@implementation LFDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    [[self.layer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.frame = self.bounds;
//    }];
//}

- (void)customInit
{
    _lineWidth = 5.f;
    _lineColor = [UIColor redColor];
    _slayerArray = [@[] mutableCopy];
    _lineArray = [@[] mutableCopy];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.exclusiveTouch = YES;
//    self.layer.anchorPoint = CGPointMake(0, 0);
//    self.layer.position = CGPointMake(0, 0);
}


#pragma mark - 创建图层
- (CAShapeLayer *)createShapeLayer:(LFDrawBezierPath *)path
{
    /** 1、渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
     2、高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
     3、不会被图层边界剪裁掉。
     4、不会出现像素化。 */
    
    CAShapeLayer *slayer = [CAShapeLayer layer];
    slayer.path = path.CGPath;
    slayer.backgroundColor = [UIColor clearColor].CGColor;
    slayer.fillColor = [UIColor clearColor].CGColor;
    slayer.lineCap = kCALineCapRound;
    slayer.lineJoin = kCALineJoinRound;
    slayer.strokeColor = path.color.CGColor;
    slayer.lineWidth = path.lineWidth;
    
    return slayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([event allTouches].count == 1) {
        _isWork = NO;
        _isBegan = YES;
        
        //1、每次触摸的时候都应该去创建一条贝塞尔曲线
        LFDrawBezierPath *path = [LFDrawBezierPath new];
        //2、移动画笔
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        //设置线宽
        path.lineWidth = self.lineWidth;
        path.lineCapStyle = kCGLineCapRound; //线条拐角
        path.lineJoinStyle = kCGLineJoinRound; //终点处理
        [path moveToPoint:point];
        path.previousPoint = point; // 保存上一个节点
        //设置颜色
        path.color = self.lineColor;//保存线条当前颜色
        [self.lineArray addObject:path];
        
        CAShapeLayer *slayer = [self createShapeLayer:path];
        [self.layer addSublayer:slayer];
        [self.slayerArray addObject:slayer];
        
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_isBegan || _isWork) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        LFDrawBezierPath *path = self.lineArray.lastObject;
        if (!CGPointEqualToPoint(path.currentPoint, point)) {
            if (_isBegan && self.drawBegan) self.drawBegan();
            _isBegan = NO;
            _isWork = YES;
            CGPoint midPoint = LFDrawMidPoint(path.previousPoint, point);
            // 使用二次曲线方程式
            [path addQuadCurveToPoint:midPoint controlPoint:path.previousPoint];
            path.previousPoint = point;
            CAShapeLayer *slayer = self.slayerArray.lastObject;
            slayer.path = path.CGPath;
            
        }        
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (_isWork) {
        if (self.drawEnded) self.drawEnded();
    } else {
        if ((_isBegan)) {
            [self undo];
        }
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isWork) {
        if (self.drawEnded) self.drawEnded();
    } else {
        if ((_isBegan)) {
            [self undo];
        }
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesCancelled:touches withEvent:event];
}

//- (void)drawRect:(CGRect)rect{
//    //遍历数组，绘制曲线
//    for (LFDrawBezierPath *path in self.lineArray) {
//        [path.color setStroke];
//        [path setLineCapStyle:kCGLineCapRound];
//        [path stroke];
//    }
//}

- (BOOL)isDrawing
{
    return _isWork;
}

/** 是否可撤销 */
- (BOOL)canUndo
{
    return self.lineArray.count;
}

//撤销
- (void)undo
{
    [self.slayerArray.lastObject removeFromSuperlayer];
    [self.slayerArray removeLastObject];
    [self.lineArray removeLastObject];
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.lineArray.count) {
        return @{kLFDrawViewData:[self.lineArray copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *lineArray = data[kLFDrawViewData];
    if (lineArray.count) {
        for (LFDrawBezierPath *path in lineArray) {
            CAShapeLayer *slayer = [self createShapeLayer:path];
            [self.layer addSublayer:slayer];
            [self.slayerArray addObject:slayer];
        }
        [self.lineArray addObjectsFromArray:lineArray];
    }
}

@end
