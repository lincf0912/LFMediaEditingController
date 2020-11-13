//
//  LFCGContextDrawTextBackground.m
//  KiraTextView
//
//  Created by LamTsanFeng on 2020/11/12.
//  Copyright © 2020 Kira. All rights reserved.
//

#import "LFCGContextDrawTextBackground.h"

LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundTypeName = @"LFCGContextDrawTextBackgroundTypeName";
LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundColorName = @"LFCGContextDrawTextBackgroundColorName";
LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundRadiusName = @"LFCGContextDrawTextBackgroundRadiusName";
LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundLineUsedRectsName = @"LFCGContextDrawTextBackgroundLineUsedRectsName";
LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundTextContainerSizeName = @"LFCGContextDrawTextBackgroundTextContainerSizeName";

static inline void lf_CGContextChangedBlendModelClear(CGContextRef cg_nullable c, BOOL isClear, UIColor * _Nullable backgroundColor)
{
    if (isClear) {
        CGContextSetBlendMode(c, kCGBlendModeClear);
        [[UIColor clearColor] setStroke];
    } else {
        CGContextSetBlendMode(c, kCGBlendModeNormal);
        if (backgroundColor) {
            [backgroundColor setFill];
            [backgroundColor setStroke];
        } else {
            [[UIColor blackColor] setFill];
            [[UIColor whiteColor] setStroke];
        }
    }
}

void lf_CGContextDrawTextBackgroundSolid(CGContextRef cg_nullable c, UIColor  * _Nullable backgroundColor, CGFloat radius, NSArray <NSValue *>*usedRects)
{
    lf_CGContextChangedBlendModelClear(c, NO, backgroundColor);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat R = 0;
    for (int i = 0; i < usedRects.count; i ++) {
        NSValue *curValue = [usedRects objectAtIndex:i];
        CGRect cur = curValue.CGRectValue;
        R = cur.size.height * radius;
        [path appendPath:[UIBezierPath bezierPathWithRoundedRect:cur cornerRadius:R]];
        CGRect last = CGRectNull;
        if (i > 0) {
            NSValue *lastValue = [usedRects objectAtIndex:i-1];
            last = lastValue.CGRectValue;
            CGPoint a = cur.origin;
            CGPoint b = CGPointMake(CGRectGetMaxX(cur), cur.origin.y);
            CGPoint c = CGPointMake(last.origin.x, CGRectGetMaxY(last));
            CGPoint d = CGPointMake(CGRectGetMaxX(last), CGRectGetMaxY(last));
            
            if (a.x - c.x >= 2*R) {
                //Draw
                //                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0 , 0, 1.0);
                //                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x - R, a.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
                
                [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES]];
                [addPath addLineToPoint:CGPointMake(a.x - R, a.y)];
                [path appendPath:addPath];
                //Remove
                
            }
            if (a.x == c.x) {
                //Draw
                [path moveToPoint:CGPointMake(a.x, a.y - R)];
                [path addLineToPoint:CGPointMake(a.x, a.y + R)];
                [path addArcWithCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
                [path addArcWithCenter:CGPointMake(a.x + R, a.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                //Remove
            }
            if (d.x - b.x >= 2*R) {
                //Draw
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x + R, b.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:M_PI clockwise:NO];
                [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:3 * M_PI_2 clockwise:NO]];
                [addPath addLineToPoint:CGPointMake(b.x + R, b.y)];
                [path appendPath:addPath];
                //Remove
                
            }
            if (d.x == b.x) {
                //Draw
                [path moveToPoint:CGPointMake(b.x, b.y - R)];
                [path addLineToPoint:CGPointMake(b.x, b.y + R)];
                [path addArcWithCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:M_PI_2 * 3 clockwise:NO];
                [path addArcWithCenter:CGPointMake(b.x - R, b.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                //Remove
            }
            if (c.x - a.x >= 2*R) {
                //Draw
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x - R, c.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x + R, c.y - R) radius:R startAngle:M_PI endAngle:M_PI_2 clockwise:NO]];
                [addPath addLineToPoint:CGPointMake(c.x - R, c.y)];
                [path appendPath:addPath];
                //Remove
            }
            if (b.x - d.x >= 2*R) {
                //Draw
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x + R, d.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                [addPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x - R, d.y - R) radius:R startAngle:0 endAngle:M_PI_2 clockwise:YES]];
                [addPath addLineToPoint:CGPointMake(d.x + R, d.y)];
                [path appendPath:addPath];
                //Remove
            }
        }
    }
    [path stroke];
    [path fill];
}

void lf_CGContextDrawTextBackgroundBorder(CGContextRef cg_nullable context, UIColor  * _Nullable backgroundColor, CGFloat radius, NSArray <NSValue *>*usedRects)
{
    CGFloat R = 0;
    CGFloat lineWidth = 0;
    for (int i = 0; i < usedRects.count; i ++) {
        NSValue *curValue = [usedRects objectAtIndex:i];
        CGRect cur = curValue.CGRectValue;
        R = cur.size.height * radius;
        lineWidth = R * 0.25;
        lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cur cornerRadius:R];
        [path setLineWidth:lineWidth];
        [path stroke];

        CGRect last = CGRectNull;
        if (i > 0) {
            NSValue *lastValue = [usedRects objectAtIndex:i-1];
            last = lastValue.CGRectValue;
            CGPoint a = cur.origin;
            CGPoint b = CGPointMake(CGRectGetMaxX(cur), cur.origin.y);
            CGPoint c = CGPointMake(last.origin.x, CGRectGetMaxY(last));
            CGPoint d = CGPointMake(CGRectGetMaxX(last), CGRectGetMaxY(last));
            CGFloat centerX = ((a.x > c.x? a.x : c.x) + (b.x > d.x? d.x : b.x)) / 2.f;
            
            if (a.x - c.x >= 2*R) {
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES]];
                [clearPath addLineToPoint:CGPointMake(centerX + 1, a.y)];
                [clearPath addLineToPoint:CGPointMake(a.x - R, a.y)];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(a.x - R, a.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
            if (a.x == c.x) {
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath addArcWithCenter:CGPointMake(a.x + R, a.y + R) radius:R startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
                [clearPath addLineToPoint:CGPointMake(centerX + 1, a.y)];
                [clearPath addArcWithCenter:CGPointMake(a.x + R, a.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPath];
                [addPath moveToPoint:CGPointMake(a.x, a.y - R)];
                [addPath addLineToPoint:CGPointMake(a.x, a.y + R)];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
            if (d.x - b.x >= 2*R) {
                
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:3 * M_PI_2 clockwise:NO]];
                [clearPath addLineToPoint:CGPointMake(centerX - 1, b.y)];
                [clearPath addLineToPoint:CGPointMake(b.x + R, b.y)];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(b.x + R, b.y + R) radius:R startAngle:M_PI_2 * 3 endAngle:M_PI clockwise:NO];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
            if (d.x == b.x) {
                
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath addArcWithCenter:CGPointMake(b.x - R, b.y + R) radius:R startAngle:0 endAngle:M_PI_2 * 3 clockwise:NO];
                [clearPath addLineToPoint:CGPointMake(centerX - 1, a.y)];
                [clearPath addArcWithCenter:CGPointMake(b.x - R, b.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPath];
                [addPath moveToPoint:CGPointMake(b.x, b.y - R)];
                [addPath addLineToPoint:CGPointMake(b.x, b.y + R)];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
            if (c.x - a.x >= 2*R) {
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x + R, c.y - R) radius:R startAngle:M_PI endAngle:M_PI_2 clockwise:NO]];
                [clearPath addLineToPoint:CGPointMake(centerX + 1, c.y)];
                [clearPath addLineToPoint:CGPointMake(c.x - R, c.y)];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x - R, c.y - R) radius:R startAngle:M_PI_2 endAngle:0 clockwise:NO];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
            if (b.x - d.x >= 2*R) {
                lf_CGContextChangedBlendModelClear(context, YES, backgroundColor);
                UIBezierPath * clearPath = [UIBezierPath bezierPath];
                [clearPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x - R, d.y - R) radius:R startAngle:0 endAngle:M_PI_2 clockwise:YES]];
                [clearPath addLineToPoint:CGPointMake(centerX - 1, d.y)];
                [clearPath addLineToPoint:CGPointMake(d.x + R, d.y)];
                [clearPath setLineWidth:lineWidth * 1.25];
                [clearPath stroke];
                
                lf_CGContextChangedBlendModelClear(context, NO, backgroundColor);
                UIBezierPath * addPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(d.x + R, d.y - R) radius:R startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
                [addPath setLineWidth:lineWidth];
                [addPath setLineCapStyle:kCGLineCapRound];
                [addPath stroke];
            }
        }
    }
}


void lf_CGContextDrawTextBackground(CGContextRef cg_nullable c, UIColor  * _Nullable backgroundColor, CGFloat radius, NSArray <NSValue *>*usedRects, LFCGContextDrawTextBackgroundType type)
{
    switch (type) {
        case LFCGContextDrawTextBackgroundTypeBorder:
            lf_CGContextDrawTextBackgroundBorder(c, backgroundColor, radius, usedRects);
            break;
        case LFCGContextDrawTextBackgroundTypeSolid:
            lf_CGContextDrawTextBackgroundSolid(c, backgroundColor, radius, usedRects);
            break;
        default:
            break;
    }
}

void lf_CGContextDrawTextBackgroundData(CGContextRef cg_nullable c, CGSize size, NSDictionary *data)
{
    UIColor *backgroundColor = [data objectForKey:LFCGContextDrawTextBackgroundColorName];
    CGFloat radius = [[data objectForKey:LFCGContextDrawTextBackgroundRadiusName] floatValue];
    NSArray <NSValue *>*usedRects = [data objectForKey:LFCGContextDrawTextBackgroundLineUsedRectsName];
    LFCGContextDrawTextBackgroundType type = [[data objectForKey:LFCGContextDrawTextBackgroundTypeName] integerValue];
    NSValue *textContainerSizeValue = [data objectForKey:LFCGContextDrawTextBackgroundTextContainerSizeName];
    if (textContainerSizeValue) {
        CGSize textContainerSize = [textContainerSizeValue CGSizeValue];
        if (textContainerSize.width != size.width) {
            /** 重置坐标x */
            NSMutableArray *tempUsedRects = @[].mutableCopy;
            CGRect rect;
            for (NSValue *value in usedRects) {
                rect = value.CGRectValue;
                if (rect.origin.x == 0) { /** 左边 */
                    [tempUsedRects addObject:value];
                } else if (rect.origin.x == (textContainerSize.width - rect.size.width)) { /** 右边 */
                    rect.origin.x = size.width - rect.size.width;
                    [tempUsedRects addObject:[NSValue valueWithCGRect:rect]];
                } else { /** 中间 */
                    CGFloat multiple = (textContainerSize.width - rect.size.width) / rect.origin.x;
                    rect.origin.x = (size.width - rect.size.width) / multiple;
                    [tempUsedRects addObject:[NSValue valueWithCGRect:rect]];
                }
            }
            usedRects = tempUsedRects.copy;
        }
    }
    lf_CGContextDrawTextBackground(c, backgroundColor, radius, usedRects, type);
}
