//
//  LFEraserBrush.h
//  DrawDemo
//
//  Created by TsanFeng Lam on 2020/3/24.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "LFPaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFEraserBrush : LFPaintBrush

/**
异步加载橡皮擦画笔

@param image 图层展示的图片
@param canvasSize 画布大小
@param useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
@param complete 回调状态(成功后可以直接使用[[LFBlurryBrush alloc] init]初始化画笔)
*/
+ (void)loadEraserImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;

/**
橡皮擦画笔缓存

@return 是否存在缓存
*/
+ (BOOL)eraserBrushCache;

/**
 创建橡皮擦画笔，创建前必须调用“异步加载橡皮擦画笔”👆
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
