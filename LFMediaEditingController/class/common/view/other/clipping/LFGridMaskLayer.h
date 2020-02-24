//
//  LFGridMaskLayer.h
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFGridMaskLayer : CAShapeLayer

/** 遮罩颜色 */
@property (nonatomic, assign) CGColorRef maskColor;
/** 圆形 */
@property (nonatomic, assign, getter=isCircle) BOOL circle;
/** 遮罩范围 */
@property (nonatomic, assign, setter=setMaskRect:) CGRect maskRect;
- (void)setMaskRect:(CGRect)maskRect animated:(BOOL)animated;
/** 取消遮罩 */
- (void)clearMask;
- (void)clearMaskWithAnimated:(BOOL)animated;

@end
