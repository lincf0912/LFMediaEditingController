//
//  LFZoomView.h
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/8.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol lf_zoomViewDelegate;

@interface LFZoomView : UIView

@property (nonatomic, strong) UIImage *image;
/** 可编辑范围 */
@property (nonatomic, assign) CGRect editRect;
/** 剪切范围 */
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, readonly) BOOL isMaxZoom;

@property (nonatomic, weak) id<lf_zoomViewDelegate> delegate;

/** 放大到指定坐标 */
- (void)zoomInToRect:(CGRect)toRect;
/** 缩小到指定坐标 */
- (void)zoomOutToRect:(CGRect)toRect;

/** 截图 */
- (UIImage *)captureImage;

@end

@protocol lf_zoomViewDelegate <NSObject>

/** 同步缩放视图（调用zoomOutToRect才会触发） */
- (void (^)(CGRect))lf_zoomViewWillBeginZooming:(LFZoomView *)zoomView;
- (void)lf_zoomViewDidEndZooming:(LFZoomView *)zoomView;

/** 移动视图 */
- (void)lf_zoomViewWillBeginDragging:(LFZoomView *)zoomView;
- (void)lf_zoomViewDidEndDecelerating:(LFZoomView *)zoomView;

@end
