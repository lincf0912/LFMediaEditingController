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
 异步加载模糊画笔

 @param image 图层展示的图片
 @param radius 模糊范围系数，越大越模糊。建议5.0
 @param canvasSize 画布大小
 @param useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 @param complete 回调状态(成功后可以直接使用[[LFBlurryBrush alloc] init]初始化画笔)
 */
+ (void)loadBrushImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;


/**
 模糊画笔缓存

 @return 是否存在缓存
 */
+ (BOOL)blurryBrushCache;

/**
 创建模糊画笔

 @param image 图层展示的图片
 @param radius 模糊范围系数，越大越模糊。建议5.0
 @param canvasSize 画布大小
 @param useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 @return 返回对象后，画笔的加载会有延迟。
 */
- (instancetype)initWithImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache;

@end

NS_ASSUME_NONNULL_END
