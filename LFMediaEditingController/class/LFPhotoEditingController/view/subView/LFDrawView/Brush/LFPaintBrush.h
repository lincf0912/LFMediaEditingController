//
//  LFPaintBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN const NSString *LFBrushLineColor;

@interface LFPaintBrush : LFBrush

/** 线颜色 */
@property (nonatomic, strong) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
