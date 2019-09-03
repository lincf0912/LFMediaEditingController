//
//  LFBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN const NSString *LFBrushClassName;
OBJC_EXTERN const NSString *LFBrushAllPoints;
OBJC_EXTERN const NSString *LFBrushLineWidth;

@interface LFBrush : NSObject

/** 线粗 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 1、创建点与画笔结合的绘画层(意味着重新绘画，重置所有数据)
 */
- (CALayer *)createDrawLayerWithPoint:(CGPoint)point;
/**
 2、结合手势的坐标
 */
- (void)addPoint:(CGPoint)point;

/**
 当前点 CGPoint(NAN, NAN)
 */
@property (nonatomic, readonly) CGPoint currentPoint;
/**
 上一个点 CGPoint(NAN, NAN)
 */
@property (nonatomic, readonly) CGPoint previousPoint;

/**
 所有轨迹数据
 */
@property (nonatomic, readonly, nullable) NSDictionary *allTracks;

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict;

@end

NS_ASSUME_NONNULL_END
