//
//  LFBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

const NSString *LFBrushClassName = @"LFBrushClassName";
const NSString *LFBrushAllPoints = @"LFBrushAllPoints";
const NSString *LFBrushLineWidth = @"LFBrushLineWidth";

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
    self.allPoints = [NSMutableArray array];
    [self.allPoints addObject:NSStringFromCGPoint(point)];
    NSAssert(![self isMemberOfClass:[LFBrush class]], @"Use subclasses of LFBrush.");
    return nil;
}

- (CGPoint)currentPoint
{
    NSString *pointStr = self.allPoints.lastObject;
    if (pointStr) {
        return CGPointFromString(pointStr);
    }
    return CGPointMake(NAN, NAN);
}

- (CGPoint)previousPoint
{
    if (self.allPoints.count > 1) {
        NSString *pointStr = [self.allPoints objectAtIndex:self.allPoints.count-2];
        return CGPointFromString(pointStr);
    }
    return CGPointMake(NAN, NAN);
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
