//
//  LFFluorescentBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFluorescentBrush.h"
#import "LFBrush+create.h"

@interface LFFluorescentBrush ()

@end

@implementation LFFluorescentBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineColor = [UIColor redColor];
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    super.lineColor = [lineColor colorWithAlphaComponent:0.5];
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
        slayer.lineCap = kCALineCapSquare;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = strokeColor.CGColor;
        slayer.lineWidth = lineWidth;
    }
    
    return slayer;
}

@end
