//
//  LFTextViewBackgroundLayoutManager.h
//  KiraTextView
//
//  Created by LamTsanFeng on 2020/11/12.
//  Copyright © 2020 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFCGContextDrawTextBackground.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFTextViewBackgroundLayoutManager : NSLayoutManager

/** 文字背景颜色 */
@property (nonatomic, strong, nullable) UIColor *usedColor;
/** 文字背景类型 */
@property (nonatomic, assign) LFCGContextDrawTextBackgroundType type;
/** 圆角度数 0.18 */
@property (nonatomic, assign) CGFloat radius;
/** 所有的绘制位置集合 CGRect */
@property (nonatomic, readonly) NSArray <NSValue *>*allUsedRects;
/** 绘制数据，交由LFCGContextDrawTextBackground使用 */
@property (nonatomic, strong) NSDictionary *layoutData;

@end

NS_ASSUME_NONNULL_END
