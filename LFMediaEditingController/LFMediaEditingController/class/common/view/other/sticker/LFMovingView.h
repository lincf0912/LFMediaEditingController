//
//  LFMovingView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/24.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFStickerItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFMovingView : UIView

/** active sticker view */
+ (void)setActiveEmoticonView:(LFMovingView * __nullable)view;

/** 初始化 */
- (instancetype)initWithItem:(LFStickerItem *)item;

/** 缩放率 minScale~maxScale */
- (void)setScale:(CGFloat)scale;
- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation;

/** 最小缩放率 默认0.2 */
@property (nonatomic, assign) CGFloat minScale;
/** 最大缩放率 默认3.0 */
@property (nonatomic, assign) CGFloat maxScale;

/** 显示界面的缩放率，例如在UIScrollView上显示，scrollView放大了5倍，movingView的视图控件会显得较大，这个属性是适配当前屏幕的比例调整控件大小 */
@property (nonatomic, assign) CGFloat screenScale;

/** Delayed deactivated time */
@property (nonatomic, assign) CGFloat deactivatedDelay;


@property (nonatomic, readonly) UIView *view;
@property (nonatomic, strong) LFStickerItem *item;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly, getter=isActive) BOOL active;

/** 区分isActive，参数的isActive是旧值，view.isActive是新值 */
@property (nonatomic, copy, nullable) void(^tapEnded)(LFMovingView *view, BOOL isActive);
@property (nonatomic, copy, nullable) void(^movingBegan)(LFMovingView *view);
@property (nonatomic, copy, nullable) void(^movingEnded)(LFMovingView *view);
/** active发送变化时激活 */
@property (nonatomic, copy, nullable) void(^movingActived)(LFMovingView *view);

@property (nonatomic, copy, nullable) BOOL(^moveCenter)(CGRect rect);

@end

NS_ASSUME_NONNULL_END
