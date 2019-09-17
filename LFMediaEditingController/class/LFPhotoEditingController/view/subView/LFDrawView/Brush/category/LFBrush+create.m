//
//  LFBrush+create.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush+create.h"

@implementation LFBrush (create)

#pragma mark - private
+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point
{
    UIBezierPath *path = [UIBezierPath new];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineJoinRound; //终点处理
    [path moveToPoint:point];
    return path;
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
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = strokeColor.CGColor;
        slayer.lineWidth = lineWidth;
    }
    
    return slayer;
}

@end

@implementation UIImage (LFBlurryBrush)

/**
 创建图案颜色
 */
- (UIColor *)LFBB_patternGaussianColorWithSize:(CGSize)size filterHandler:(CIFilter *(^)(CIImage *ciimage))filterHandler
{
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
    CIImage *midImage = [CIImage imageWithCGImage:self.CGImage];
    midImage = [midImage imageByApplyingTransform:[self LFBB_preferredTransform]];
    midImage = [midImage imageByApplyingTransform:CGAffineTransformMakeScale(size.width/self.size.width, size.height/self.size.height)];
    //翻转图片（因为图片转换成图像颜色后在layer上使用，layer的画布是反转的，这里需要翻转方向。理应这里不应该调整方向，为了提高效率，这里的方法私有化，仅为LFBlurryBrush提供。）
    midImage = [midImage imageByApplyingOrientation:4];
    //图片开始处理
    CIImage *result = midImage;
    if (filterHandler) {
        CIFilter *filter = filterHandler(midImage);
        if (filter) {
            result = filter.outputImage;
        }
    }
    
    CGImageRef outImage = [context createCGImage:result fromRect:[midImage extent]];
    context = nil;
    UIImage *image = [UIImage imageWithCGImage:outImage];
    
    return [UIColor colorWithPatternImage:image];
}

- (CGAffineTransform)LFBB_preferredTransform {
    if (self.imageOrientation == UIImageOrientationUp) {
        return CGAffineTransformIdentity;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

@end
