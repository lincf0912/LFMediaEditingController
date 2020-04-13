//
//  NSAttributedString+LFMECoreText.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/8/26.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "NSAttributedString+LFMECoreText.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (LFMECoreText)

- (CGSize)LFME_sizeWithConstrainedToSize:(CGSize)size
{
    if (self.length == 0) return CGSizeZero;
    
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self length]), NULL, size, NULL);
    CFRelease(framesetter);
    
//    /**
//     修复CTFramesetterSuggestFrameSizeWithConstraints对空格的计算存在的bug
//     */
//    
//    if ([[self.string substringWithRange:NSMakeRange(self.length-1, 1)] isEqualToString:@" "]) {
//        // 最后一个为空格，计算的宽度会忽略空格，使用boundingRectWithSize计算宽度。
//        CGFloat width = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.width;
//        result.width = MAX(result.width, width);
//    }
    
    return result;
}

- (void)LFME_drawInContext:(CGContextRef)context withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width
{
    CGSize size = CGSizeMake(width, height);
    // 翻转坐标系
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,height);
    CGContextScaleCTM(context,1.0,-1.0);
    
    // 创建绘制区域（路径）
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(p.x, height-p.y-size.height,(size.width),(size.height)));
    
    // 创建CFAttributedStringRef
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self;
    
    // 绘制frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,0),path,NULL);
    CTFrameDraw(ctframe,context);
    CGPathRelease(path);
    CFRelease(framesetter);
    CFRelease(ctframe);
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, height);
    CGContextScaleCTM(context,1.0,-1.0);
}

@end
