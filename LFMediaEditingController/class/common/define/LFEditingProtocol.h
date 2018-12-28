//
//  LFEditingProtocol.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFPhotoEditDelegate.h"
#import "LFColorMatrixType.h"

@class LFText;
@protocol LFEditingProtocol <NSObject>

/** 代理 */
@property (nonatomic ,weak) id<LFPhotoEditDelegate> editDelegate;

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable;

/** =====================数据===================== */

/** 数据 */
@property (nonatomic, strong) NSDictionary *photoEditData;

@optional
/** =====================滤镜功能===================== */
/** 滤镜类型 */
- (void)changeFilterColorMatrixType:(LFColorMatrixType)cmType;
/** 当前使用滤镜类型 */
- (LFColorMatrixType)getFilterColorMatrixType;
/** 获取滤镜图片 */
- (UIImage *)getFilterImage;

@required
/** =====================绘画功能===================== */

/** 启用绘画功能 */
@property (nonatomic, assign) BOOL drawEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL drawCanUndo;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 撤销绘画 */
- (void)drawUndo;
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color;
/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth;

/** =====================贴图功能===================== */
/** 取消激活贴图 */
- (void)stickerDeactivated;
/** 激活选中的贴图 */
- (void)activeSelectStickerView;
/** 删除选中贴图 */
- (void)removeSelectStickerView;
/** 屏幕缩放率 */
- (void)setScreenScale:(CGFloat)scale;
/** 最小缩放率 默认0.2 */
@property (nonatomic, assign) CGFloat stickerMinScale;
/** 最大缩放率 默认3.0 */
@property (nonatomic, assign) CGFloat stickerMaxScale;

/** 创建贴图 */
- (void)createStickerImage:(UIImage *)image;

/** =====================文字功能===================== */

/** 获取选中贴图的内容 */
- (LFText *)getSelectStickerText;
/** 更改选中贴图内容 */
- (void)changeSelectStickerText:(LFText *)text;
/** 创建文字 */
- (void)createStickerText:(LFText *)text;

/** =====================模糊功能===================== */

/** 启用模糊功能 */
@property (nonatomic, assign) BOOL splashEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL splashCanUndo;
/** 正在模糊 */
@property (nonatomic, readonly) BOOL isSplashing;
/** 撤销模糊 */
- (void)splashUndo;
/** 改变模糊状态 */
@property (nonatomic, readwrite) BOOL splashState;
/** 设置马赛克大小 */
- (void)setSplashWidth:(CGFloat)squareWidth;
/** 设置画笔大小 */
- (void)setPaintWidth:(CGFloat)paintWidth;

@end
