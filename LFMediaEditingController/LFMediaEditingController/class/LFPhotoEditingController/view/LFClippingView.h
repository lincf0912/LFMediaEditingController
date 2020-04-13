//
//  LFClippingView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFScrollView.h"
#import "LFEditingProtocol.h"

@protocol LFClippingViewDelegate;

@interface LFClippingView : LFScrollView <LFEditingProtocol>

@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate;

@property (nonatomic, weak) id<LFClippingViewDelegate> clippingDelegate;
/** 首次缩放后需要记录最小缩放值 */
@property (nonatomic, readonly) CGFloat first_minimumZoomScale;
/** 与父视图中心偏差坐标 */
@property (nonatomic, assign) CGPoint offsetSuperCenter;

/** 是否重置中 */
@property (nonatomic, readonly) BOOL isReseting;
/** 是否旋转中 */
@property (nonatomic, readonly) BOOL isRotating;
/** 是否缩放中 */
//@property (nonatomic, readonly) BOOL isZooming;
/** 是否可还原 */
@property (nonatomic, readonly) BOOL canReset;
/** 以某个位置作为可还原的参照物 */
- (BOOL)canResetWithRect:(CGRect)trueFrame;

/** 可编辑范围 */
@property (nonatomic, assign) CGRect editRect;
/** 剪切范围 */
@property (nonatomic, assign) CGRect cropRect;
/** 手势开关，一般编辑模式下开启 默认NO */
@property (nonatomic, assign) BOOL useGesture;

/** 缩小到指定坐标 */
- (void)zoomOutToRect:(CGRect)toRect;
/** 放大到指定坐标(必须大于当前坐标) */
- (void)zoomInToRect:(CGRect)toRect;
/** 旋转 */
- (void)rotateClockwise:(BOOL)clockwise;
/** 还原 */
- (void)reset;
/** 还原到某个位置 */
- (void)resetToRect:(CGRect)rect;
/** 取消 */
- (void)cancel;

@end

@protocol LFClippingViewDelegate <NSObject>

/** 同步缩放视图（调用zoomOutToRect才会触发） */
- (void (^)(CGRect))lf_clippingViewWillBeginZooming:(LFClippingView *)clippingView;
- (void)lf_clippingViewDidZoom:(LFClippingView *)clippingView;
- (void)lf_clippingViewDidEndZooming:(LFClippingView *)clippingView;

/** 移动视图 */
- (void)lf_clippingViewWillBeginDragging:(LFClippingView *)clippingView;
- (void)lf_clippingViewDidEndDecelerating:(LFClippingView *)clippingView;


@end
