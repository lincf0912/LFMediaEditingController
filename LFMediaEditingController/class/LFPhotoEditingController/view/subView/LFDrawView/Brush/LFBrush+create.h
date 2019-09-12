//
//  LFBrush+create.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFBrush (create)

+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point;

+ (CAShapeLayer *)createShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor;

@end

@interface UIImage (LFBlurryBrush)

/**
 创建图案颜色
 */
- (UIColor *)LFBB_patternGaussianColorWithSize:(CGSize)size filterHandler:(CIFilter *(^)(CIImage *ciimage))filterHandler;

@end

NS_ASSUME_NONNULL_END
