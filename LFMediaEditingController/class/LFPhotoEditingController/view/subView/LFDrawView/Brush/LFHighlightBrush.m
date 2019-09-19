//
//  LFHighlightBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/5.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFHighlightBrush.h"
#import "LFBrush+create.h"

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
        _outerLineWidth = self.lineWidth/1.6;
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
    if (self.lineColor && self.outerLineColor) {
        [super createDrawLayerWithPoint:point];
        
        /**
         首次创建UIBezierPath
         */
        self.path = [[self class] createBezierPathWithPoint:point];
        
        CALayer *layer = [CALayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.lf_level = self.level;
        self.layer = layer;
        
        CAShapeLayer *outerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth+self.outerLineWidth*2 strokeColor:self.outerLineColor];
        [layer addSublayer:outerLayer];
        self.outerLayer = outerLayer;
        
        CAShapeLayer *innerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth strokeColor:self.lineColor];
        [layer addSublayer:innerLayer];
        self.innerLayer = innerLayer;
        
        return layer;
    }
    return nil;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.lineColor && self.outerLineColor) {
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
        CGPoint previousPoint = CGPointFromString(allPoints.firstObject);
        UIBezierPath *path = [[self class] createBezierPathWithPoint:previousPoint];
        for (NSInteger i=1; i<allPoints.count; i++) {
            
            CGPoint point = CGPointFromString(allPoints[i]);

            CGPoint midPoint = LFBrushMidPoint(previousPoint, point);
            // 使用二次曲线方程式
            [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
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

@end
