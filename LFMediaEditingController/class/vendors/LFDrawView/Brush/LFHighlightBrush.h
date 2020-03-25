//
//  LFHighlightBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/5.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const LFHighlightBrushLineColor;
OBJC_EXTERN NSString *const LFHighlightBrushOuterLineWidth;
OBJC_EXTERN NSString *const LFHighlightBrushOuterLineColor;

@interface LFHighlightBrush : LFBrush

/** 外边颜色 默认红色 */
@property (nonatomic, strong) UIColor *outerLineColor;
/** 外边线粗（一边） 默认3 */
@property (nonatomic, assign) CGFloat outerLineWidth;

/** 线颜色 默认白色 */
@property (nonatomic, strong) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
