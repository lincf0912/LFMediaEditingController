//
//  LFBlurryBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFPaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFBlurryBrush : LFPaintBrush

/**
 创建模糊画笔

 @param image 图层展示的图片
 @param radius 模糊范围系数，越大越模糊。建议5.0
 @param canvasSize 画布大小
 @param useCache 是否使用缓存。如果image不变，建议使用缓存。
 @return self
 */
- (instancetype)initWithImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache;

@end

NS_ASSUME_NONNULL_END
