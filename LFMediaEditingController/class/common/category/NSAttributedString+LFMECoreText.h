//
//  NSAttributedString+LFMECoreText.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/8/26.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (LFMECoreText)


/**
 *  @author lincf, 16-09-19 11:09:24
 *
 *  计算文字大小
 *
 *  @param size          最大范围 文字长度、文字高度
 *
 *  @return 文字大小
 */
- (CGSize)LFME_sizeWithConstrainedToSize:(CGSize)size;


/**
 *  @author lincf, 16-09-19 17:09:20
 *
 *  绘制文字
 *
 *  @param context       画布
 *  @param p             坐标
 *  @param height        高度
 *  @param width         宽度
 */
- (void)LFME_drawInContext:(CGContextRef)context withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width;

@end

NS_ASSUME_NONNULL_END
