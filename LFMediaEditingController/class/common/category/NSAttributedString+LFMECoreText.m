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
    /**
     修复CTFramesetterSuggestFrameSizeWithConstraints对空格的计算存在的bug，替换其他字符代替空格计算大小。
     */
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self;
    NSString *replaceStr = @" ", *toStr = @"*";
    if ([self.string containsString:replaceStr]) {
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
        while ([mutableAttributedString.mutableString containsString:replaceStr]) {
            NSRange range = [mutableAttributedString.mutableString rangeOfString:replaceStr];
            NSDictionary *attributes = [mutableAttributedString attributesAtIndex:range.location effectiveRange:nil];
            [mutableAttributedString replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:toStr attributes:attributes]];
        }
        attributedString = (__bridge CFAttributedStringRef)[mutableAttributedString attributedSubstringFromRange:NSMakeRange(0, mutableAttributedString.length)];
    }
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self length]), NULL, size, NULL);
    CFRelease(framesetter);
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
