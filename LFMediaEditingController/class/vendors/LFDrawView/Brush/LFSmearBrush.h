//
//  LFSmearBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/16.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFSmearBrush : LFBrush


/**
 异步加载涂抹画笔

 @param image 图层展示的图片
 @param canvasSize 画布大小
 @param useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 @param complete 回调状态(成功后可以直接使用[[LFSmearBrush alloc] init]初始化画笔)
 */
+ (void)loadBrushImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;


/**
 涂抹画笔缓存

 @return 是否存在缓存
 */
+ (BOOL)smearBrushCache;


/**
 创建涂抹画笔，创建前必须调用“异步加载涂抹画笔”👆

 @param name 涂抹图片
 */
- (instancetype)initWithImageName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
