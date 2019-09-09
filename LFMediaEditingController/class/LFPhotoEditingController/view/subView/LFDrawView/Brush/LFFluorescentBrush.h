//
//  LFFluorescentBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const LFFluorescentBrushLineColor;

@interface LFFluorescentBrush : LFBrush

/** 线颜色 默认红色 */
@property (nonatomic, strong) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
