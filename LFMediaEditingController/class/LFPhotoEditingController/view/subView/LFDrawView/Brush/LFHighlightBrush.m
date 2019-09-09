//
//  LFHighlightBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/5.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFHighlightBrush.h"

NSString *const LFHighlightBrushLineColor = @"LFHighlightBrushLineColor";
NSString *const LFHighlightBrushOuterLineWidth = @"LFHighlightBrushOuterLineWidth";
NSString *const LFHighlightBrushOuterLineColor = @"LFHighlightBrushOuterLineColor";

CGFloat const LFHighlightBrushAlpha = 0.6;


@interface LFHighlightBrush ()

@property (nonatomic, weak) CALayer *layer;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, weak) CAShapeLayer *innerLayer;
@property (nonatomic, weak) CAShapeLayer *outerLayer;

@end

@implementation LFHighlightBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineColor = [UIColor whiteColor];
        _outerLineColor = [UIColor redColor];
        _outerLineWidth = 3.0;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    if (self.path) {
        CGPoint midPoint = LFBrushMidPoint(self.previousPoint, point);
        // 使用二次曲线方程式
        [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousPoint];
        
        self.outerLayer.path = self.path.CGPath;
        self.innerLayer.path = self.path.CGPath;
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    [super createDrawLayerWithPoint:point];
    /**
     首次创建UIBezierPath
     */
    self.path = [[self class] createBezierPathWithPoint:point];
    
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer = layer;
    
    CAShapeLayer *outerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth+self.outerLineWidth*2 strokeColor:self.outerLineColor];
    [layer addSublayer:outerLayer];
    self.outerLayer = outerLayer;
    
    CAShapeLayer *innerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth strokeColor:self.lineColor];
    [layer addSublayer:innerLayer];
    self.innerLayer = innerLayer;
    
    return layer;
}

- (CGPoint)currentPoint
{
    return self.path.currentPoint;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{LFHighlightBrushLineColor:self.lineColor,
                                                LFHighlightBrushOuterLineColor:self.outerLineColor,
                                                LFHighlightBrushOuterLineWidth:@(self.outerLineWidth)
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[LFBrushLineWidth] floatValue];
    UIColor *lineColor = trackDict[LFHighlightBrushLineColor];
    CGFloat outerLineWidth = [trackDict[LFHighlightBrushOuterLineWidth] floatValue];
    UIColor *outerLineColor = trackDict[LFHighlightBrushOuterLineColor];
    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[LFBrushAllPoints];
    
    if (allPoints) {
        UIBezierPath *path = nil;
        CGPoint previousPoint = CGPointZero;
        for (NSString *pointStr in allPoints) {
            CGPoint point = CGPointFromString(pointStr);
            if (path == nil) {
                path = [[self class] createBezierPathWithPoint:point];
            } else {
                CGPoint midPoint = LFBrushMidPoint(previousPoint, point);
                // 使用二次曲线方程式
                [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            }
            previousPoint = point;
        }
        CALayer *layer = [CALayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        
        CAShapeLayer *outerLayer = [[self class] createShapeLayerWithPath:path lineWidth:lineWidth+outerLineWidth*2 strokeColor:outerLineColor];
        [layer addSublayer:outerLayer];
        
        CAShapeLayer *innerLayer = [[self class] createShapeLayerWithPath:path lineWidth:lineWidth strokeColor:lineColor];
        [layer addSublayer:innerLayer];
        
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point
{
    UIBezierPath *path = [UIBezierPath new];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineJoinRound; //终点处理
    [path moveToPoint:point];
    return path;
}

+ (CAShapeLayer *)createShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor
{
    /**
     1、渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
     2、高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
     3、不会被图层边界剪裁掉。
     4、不会出现像素化。
     */
    CAShapeLayer *slayer = nil;
    if (path) {
        slayer = [CAShapeLayer layer];
        slayer.path = path.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = strokeColor.CGColor;
        slayer.lineWidth = lineWidth;
    }
    
    return slayer;
}

@end
