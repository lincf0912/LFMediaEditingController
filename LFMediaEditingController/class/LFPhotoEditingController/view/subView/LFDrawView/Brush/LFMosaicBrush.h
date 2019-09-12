//
//  LFMosaicBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFPaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFMosaicBrush : LFPaintBrush

/**
 创建马赛克画笔
 
 @param image 图层展示的图片
 @param scale 马赛克大小系数。建议15.0
 @param canvasSize 画布大小
 @param useCache 是否使用缓存。如果image不变，建议使用缓存。
 @return self
 */
- (instancetype)initWithImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache;

@end

NS_ASSUME_NONNULL_END
