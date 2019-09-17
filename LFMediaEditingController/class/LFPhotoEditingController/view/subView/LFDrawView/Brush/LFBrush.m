//
//  LFBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NSString *const LFBrushClassName = @"LFBrushClassName";
NSString *const LFBrushAllPoints = @"LFBrushAllPoints";
NSString *const LFBrushLineWidth = @"LFBrushLineWidth";

const CGPoint LFBrushPointNull = {INFINITY, INFINITY};

bool LFBrushPointIsNull(CGPoint point)
{
    return isinf(point.x) || isinf(point.y);
}

CGPoint LFBrushMidPoint(CGPoint p0, CGPoint p1) {
    if (LFBrushPointIsNull(p0) || LFBrushPointIsNull(p1)) {
        return CGPointZero;
    }
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

CGFloat LFBrushDistancePoint(CGPoint p0, CGPoint p1) {
    if (LFBrushPointIsNull(p0) || LFBrushPointIsNull(p1)) {
        return 0;
    }
    return sqrt(pow(p0.x - p1.x, 2) + pow(p0.y - p1.y, 2));
}

CGFloat LFBrushAngleBetweenPoint(CGPoint p0, CGPoint p1) {
    
    if (LFBrushPointIsNull(p0) || LFBrushPointIsNull(p1)) {
        return 0;
    }
    
    CGPoint p = CGPointMake(p0.x, p0.y+100);
    
    CGFloat x1 = p.x - p0.x;
    CGFloat y1 = p.y - p0.y;
    CGFloat x2 = p1.x - p0.x;
    CGFloat y2 = p1.y - p0.y;
    
    CGFloat x = x1 * x2 + y1 * y2;
    CGFloat y = x1 * y2 - x2 * y1;
    
    CGFloat angle = acos(x/sqrt(x*x+y*y));
    
    if (p1.x < p0.x) {
        angle = M_PI*2 - angle;
    }
    
    return (180.0 * angle / M_PI);
}

@interface LFBrush ()

@property (nonatomic, strong) NSMutableArray <NSString /*CGPoint*/*>*allPoints;

@end

@implementation LFBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = 5.f;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [self.allPoints addObject:NSStringFromCGPoint(point)];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    NSAssert(![self isMemberOfClass:[LFBrush class]], @"Use subclasses of LFBrush.");
    self.allPoints = [NSMutableArray array];
    if (LFBrushPointIsNull(point)) {
        return nil;
    }
    [self.allPoints addObject:NSStringFromCGPoint(point)];
    return nil;
}

- (CGPoint)currentPoint
{
    NSString *pointStr = self.allPoints.lastObject;
    if (pointStr) {
        return CGPointFromString(pointStr);
    }
    return LFBrushPointNull;
}

- (CGPoint)previousPoint
{
    if (self.allPoints.count > 1) {
        NSString *pointStr = [self.allPoints objectAtIndex:self.allPoints.count-2];
        return CGPointFromString(pointStr);
    }
    return LFBrushPointNull;
}

- (NSDictionary *)allTracks
{
    if (self.allPoints.count) {
        return @{LFBrushClassName:NSStringFromClass(self.class),
                 LFBrushAllPoints:self.allPoints,
                 LFBrushLineWidth:@(self.lineWidth)};
    }
    return nil;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    NSString *className = trackDict[LFBrushClassName];
    Class class = NSClassFromString(className);
    if (class) {
        return [class drawLayerWithTrackDict:trackDict];
    }
    return nil;
}

@end
