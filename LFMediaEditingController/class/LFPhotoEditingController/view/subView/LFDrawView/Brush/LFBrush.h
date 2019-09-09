//
//  LFBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const LFBrushClassName;
OBJC_EXTERN NSString *const LFBrushAllPoints;
OBJC_EXTERN NSString *const LFBrushLineWidth;

// 为CGPoint{inf, inf}
OBJC_EXTERN const CGPoint LFBrushPointNull;

OBJC_EXTERN bool LFBrushPointIsNull(CGPoint point);

OBJC_EXTERN CGPoint LFBrushMidPoint(CGPoint p0, CGPoint p1);

OBJC_EXTERN CGFloat LFBrushDistancePoint(CGPoint p0, CGPoint p1);

@interface LFBrush : NSObject

/** 线粗 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 1、创建点与画笔结合的绘画层(意味着重新绘画，重置轨迹数据)；应在手势开始时调用，例如：touchesBegan，若需要忽略轨迹坐标，入参修改为CGPoint{inf, inf}
 */
- (CALayer *)createDrawLayerWithPoint:(CGPoint)point;
/**
 2、结合手势的坐标（手势移动时产生的坐标）；应在手势移动时调用，例如：touchesMoved
 */
- (void)addPoint:(CGPoint)point;

/**
 当前点。如果没值，回调CGPoint{inf, inf}
 */
@property (nonatomic, readonly) CGPoint currentPoint;
/**
 上一个点。如果没值，回调CGPoint{inf, inf}
 */
@property (nonatomic, readonly) CGPoint previousPoint;

/**
 所有轨迹数据；应在手势结束时调用，例如：touchesEnded、touchesCancelled
 */
@property (nonatomic, readonly, nullable) NSDictionary *allTracks;

/**
 使用轨迹数据恢复绘画层，持有所有轨迹数据，轻松实现undo、redo操作。
 */
+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict;

@end

NS_ASSUME_NONNULL_END
