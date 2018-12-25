//
//  LFStickerView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/24.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LFText;
@interface LFStickerView : UIView

/** 取消当前激活的贴图 */
+ (void)LFStickerViewDeactivated;

/** 激活选中的贴图 */
- (void)activeSelectStickerView;
/** 删除选中贴图 */
- (void)removeSelectStickerView;

/** 获取选中贴图的内容 */
- (UIImage *)getSelectStickerImage;
- (LFText *)getSelectStickerText;

/** 更改选中贴图内容 */
- (void)changeSelectStickerImage:(UIImage *)image;
- (void)changeSelectStickerText:(LFText *)text;

/** 创建图片 */
- (void)createImage:(UIImage *)image;
- (void)createImage:(UIImage *)image scale:(CGFloat)scale;
/** 创建文字 */
- (void)createText:(LFText *)text;
- (void)createText:(LFText *)text scale:(CGFloat)scale;

/** 显示界面的缩放率，例如在UIScrollView上显示，scrollView放大了5倍，movingView的视图控件会显得较大，这个属性是适配当前屏幕的比例调整控件大小 */
@property (nonatomic, assign) CGFloat screenScale;

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 点击回调视图 */
@property (nonatomic, copy) void(^tapEnded)(BOOL isActive);
@property (nonatomic, copy) BOOL(^moveCenter)(CGRect rect);

@end
