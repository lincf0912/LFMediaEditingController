//
//  LFEditingProtocol.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFPhotoEditDelegate.h"
#import "LFStickerItem.h"
#import "LFMediaEditingType.h"

#import "LFDrawViewHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class LFBrush, LFDrawView, LFStickerView, LFDataFilterImageView, LFDataFilterVideoView;
@protocol LFEditingProtocol, LFFilterDataProtocol;

// 实现LFEditingProtocol的所有非必要方法。
@interface UIView (LFEditingProtocol)

// 协议执行者
@property (nonatomic, weak) UIView <LFEditingProtocol>* lf_protocolxecutor;

/** 绘画 */
@property (nonatomic, weak) LFDrawView *lf_drawView;
/** 贴图 */
@property (nonatomic, weak) LFStickerView *lf_stickerView;
/** 模糊（马赛克、高斯模糊、涂抹） */
@property (nonatomic, weak) LFDrawView *lf_splashView;

/** 展示 */
@property (nonatomic, weak) id<LFFilterDataProtocol> lf_displayView;

- (void)clearProtocolxecutor;

@end

@protocol LFEditingProtocol <NSObject>

/** =====================数据===================== */

/** 数据 */
@property (nonatomic, strong, nullable) NSDictionary *photoEditData;

@optional
/** =====================设置项===================== */
/** 代理 */
@property (nonatomic, weak) id<LFPhotoEditDelegate> editDelegate;

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable;

/** =====================绘画功能===================== */

/** 启用绘画功能 */
@property (nonatomic, assign) BOOL drawEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL drawCanUndo;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 撤销绘画 */
- (void)drawUndo;
/** 设置绘画画笔 */
- (void)setDrawBrush:(LFBrush *)brush;
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color;
/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth;

/** =====================贴图功能===================== */
/** 贴图启用 */
@property (nonatomic, readonly) BOOL stickerEnable;
/** 取消激活贴图 */
- (void)stickerDeactivated;
/** 激活选中的贴图 */
- (void)activeSelectStickerView;
/** 删除选中贴图 */
- (void)removeSelectStickerView;
/** 屏幕缩放率 */
@property (nonatomic, assign) CGFloat screenScale;
/** 最小缩放率 */
@property (nonatomic, assign) CGFloat stickerMinScale;
/** 最大缩放率 */
@property (nonatomic, assign) CGFloat stickerMaxScale;

/** 创建贴图 */
- (void)createSticker:(LFStickerItem *)item;
/** 获取选中贴图的内容 */
- (LFStickerItem *)getSelectSticker;
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(LFStickerItem *)item;

/** =====================模糊功能===================== */

/** 启用模糊功能 */
@property (nonatomic, assign) BOOL splashEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL splashCanUndo;
/** 正在模糊 */
@property (nonatomic, readonly) BOOL isSplashing;
/** 撤销模糊 */
- (void)splashUndo;
/** 设置模糊类型 */
@property (nonatomic, assign) LFSplashStateType splashStateType;
/** 设置模糊线粗 */
- (void)setSplashLineWidth:(CGFloat)lineWidth;

/** =====================滤镜功能===================== */
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType;
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType;
/** 获取滤镜图片 */
- (UIImage *)getFilterImage;

@end

NS_ASSUME_NONNULL_END
