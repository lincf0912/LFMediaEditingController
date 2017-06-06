//
//  LFGridMaskLayer.m
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFGridMaskLayer.h"

@implementation LFGridMaskLayer

@synthesize maskColor = _maskColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    
}

- (void)setMaskColor:(CGColorRef)maskColor
{
    self.fillColor = maskColor;
    self.fillRule = kCAFillRuleEvenOdd;
}

- (CGColorRef)maskColor
{
    return self.fillColor;
}

- (void)setMaskRect:(CGRect)maskRect
{
    [self removeAnimationForKey:@"lf_maskLayer_opacityAnimate"];
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddRect(mPath, NULL, self.bounds);
    CGPathAddRect(mPath, NULL, maskRect);
    
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animate.duration = 0.25f;
    animate.fromValue = @(0.0);
    animate.toValue = @(1.0);
    self.path = mPath;
    [self addAnimation:animate forKey:@"lf_maskLayer_opacityAnimate"];
}

@end
