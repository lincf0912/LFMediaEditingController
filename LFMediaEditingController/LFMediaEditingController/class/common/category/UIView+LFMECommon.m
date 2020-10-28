//
//  UIView+LFCommon.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "UIView+LFMECommon.h"

@implementation UIView (LFMECommon)

- (UIImage *)LFME_captureImage
{
    return [self LFME_captureImageAtFrame:CGRectZero];
}

- (UIImage *)LFME_captureImageAtFrame:(CGRect)rect
{
    
    UIImage* image = nil;
    
    if (/* DISABLES CODE */ (YES)) {
        CGSize size = self.bounds.size;
        CGPoint point = self.bounds.origin;
        if (!CGRectEqualToRect(CGRectZero, rect)) {
            size = rect.size;
            point = CGPointMake(-rect.origin.x, -rect.origin.y);
        }
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [self drawViewHierarchyInRect:(CGRect){point, self.bounds.size} afterScreenUpdates:YES];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
    } else {
        
            BOOL translateCTM = !CGRectEqualToRect(CGRectZero, rect);
        
            if (!translateCTM) {
                rect = self.frame;
            }
        
            /** 参数取整，否则可能会出现1像素偏差 */
            /** 有小数部分才调整差值 */
#define lfme_fixDecimal(d) ((fmod(d, (int)d)) > 0.59f ? ((int)(d+0.5)*1.f) : (((fmod(d, (int)d)) < 0.59f && (fmod(d, (int)d)) > 0.1f) ? ((int)(d)*1.f+0.5f) : (int)(d)*1.f))
            rect.origin.x = lfme_fixDecimal(rect.origin.x);
            rect.origin.y = lfme_fixDecimal(rect.origin.y);
            rect.size.width = lfme_fixDecimal(rect.size.width);
            rect.size.height = lfme_fixDecimal(rect.size.height);
#undef lfme_fixDecimal
            CGSize size = rect.size;
        
        @autoreleasepool {
            //1.开启上下文
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (translateCTM) {
                /** 移动上下文 */
                CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
            }
            //2.绘制图层
            [self.layer renderInContext: context];
            
            //3.从上下文中获取新图片
            image = UIGraphicsGetImageFromCurrentImageContext();
            
            //4.关闭图形上下文
            UIGraphicsEndImageContext();
            
            //    if (translateCTM) {
            //        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
            //        [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
            //        image = UIGraphicsGetImageFromCurrentImageContext();
            //        UIGraphicsEndImageContext();
            //    }
        }
        
    }
    
    
    return image;
}

- (UIColor *)LFME_colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (void)LFME_setCornerRadius:(float)cornerRadius
{
    if (cornerRadius > 0) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = cornerRadius;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 0;
        self.layer.shouldRasterize = NO;
        self.layer.rasterizationScale = 1.f;
    }
}

- (void)LFME_setCornerRadiusWithoutMasks:(float)cornerRadius
{
    if (cornerRadius > 0) {
        self.layer.cornerRadius = cornerRadius;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.shouldRasterize = NO;
        self.layer.rasterizationScale = 1.f;
    }
}

/** 设置阴影 */
- (void)LFME_updateSquareShadow
{
    CGFloat shadowRadius = self.layer.shadowRadius;
    
    if (shadowRadius == 0) {
        self.layer.shadowPath = nil;
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(-shadowRadius/2, 0, shadowRadius, self.bounds.size.height-shadowRadius)];
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(shadowRadius/2, -shadowRadius/2, self.bounds.size.width-shadowRadius, shadowRadius)];
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.size.width-shadowRadius/2, shadowRadius, shadowRadius, self.bounds.size.height-shadowRadius)];
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.bounds.size.height-shadowRadius/2, self.bounds.size.width-shadowRadius, shadowRadius)];
    [path appendPath:topPath];
    [path appendPath:leftPath];
    [path appendPath:rightPath];
    [path appendPath:bottomPath];
    
    self.layer.shadowPath = path.CGPath;
}

/** 设置阴影（圆） */
- (void)LFME_updateCircleShadow
{
    CGFloat shadowRadius = self.layer.shadowRadius;
    
    if (shadowRadius == 0) {
        self.layer.shadowPath = nil;
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -shadowRadius/2, -shadowRadius/2) cornerRadius:self.bounds.size.width/2];
    path.lineJoinStyle = kCGLineJoinRound;
    
    self.layer.shadowPath = path.CGPath;
}

@end
