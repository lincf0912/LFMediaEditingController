//
//  LFEditingView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/10.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFEditingView.h"
#import "LFGridView.h"
#import "LFClippingView.h"

#import "UIView+LFMEFrame.h"
#import "LFMECancelBlock.h"
#import "UIView+LFMECommon.h"
#import "UIImage+LFMECommon.h"

#import <AVFoundation/AVFoundation.h>

#define kMaxZoomScale 2.5f

@interface LFEditingView () <UIScrollViewDelegate, LFClippingViewDelegate, LFGridViewDelegate>

@property (nonatomic, weak) LFClippingView *clippingView;
@property (nonatomic, weak) LFGridView *gridView;
/** 因为LFClippingView需要调整transform属性，需要额外创建一层进行缩放处理，理由：UIScrollView的缩放会自动重置transform */
@property (nonatomic, weak) UIView *clipZoomView;

/** 剪裁尺寸, CGRectInset(self.bounds, 30, 50) */
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, copy) lf_me_dispatch_cancelable_block_t maskViewBlock;

@end

@implementation LFEditingView

@synthesize image = _image;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    /** 缩放 */
    self.bouncesZoom = YES;
    self.maximumZoomScale = kMaxZoomScale;
    self.minimumZoomScale = 1.0;
    
    LFClippingView *clippingView = [[LFClippingView alloc] initWithFrame:self.bounds];
    clippingView.clippingDelegate = self;
    /** 创建缩放层，避免直接缩放LFClippingView，会改变其transform */
    UIView *clipZoomView = [[UIView alloc] initWithFrame:self.bounds];
    clipZoomView.backgroundColor = [UIColor clearColor];
    [clipZoomView addSubview:clippingView];
    [self addSubview:clipZoomView];
    self.clippingView = clippingView;
    self.clipZoomView = clipZoomView;
    
    LFGridView *gridView = [[LFGridView alloc] initWithFrame:self.bounds];
    gridView.delegate = self;
    /** 先隐藏剪裁网格 */
    gridView.alpha = 0.f;
    [self addSubview:gridView];
    self.gridView = gridView;
    
    self.clippingMinSize = CGSizeMake(80, 80);
    self.clippingMaxRect = CGRectInset(self.frame , 20, 50);
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.frame);
        self.gridView.gridRect = cropRect;
    }
    self.clippingView.image = image;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    self.gridView.gridRect = clippingRect;
    self.clippingView.cropRect = clippingRect;
    
    if (_isClipping) {
        /** 关闭缩放 */
        self.maximumZoomScale = self.minimumZoomScale;
        [self setZoomScale:self.zoomScale];
    } else {
        self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + kMaxZoomScale - kMaxZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), kMaxZoomScale);
    }
}

- (void)setClippingMinSize:(CGSize)clippingMinSize
{
    if (CGSizeEqualToSize(CGSizeZero, _clippingMinSize) || (clippingMinSize.width < CGRectGetWidth(_clippingMaxRect) && clippingMinSize.height < CGRectGetHeight(_clippingMaxRect))) {
        _clippingMinSize = clippingMinSize;
        self.gridView.controlMinSize = clippingMinSize;
    }
}

- (void)setClippingMaxRect:(CGRect)clippingMaxRect
{
    if (CGRectEqualToRect(CGRectZero, _clippingMaxRect) || (CGRectGetWidth(clippingMaxRect) > _clippingMinSize.width && CGRectGetHeight(clippingMaxRect) > _clippingMinSize.height)) {
        _clippingMaxRect = clippingMaxRect;
        self.gridView.controlMaxRect = clippingMaxRect;
        self.clippingView.editRect = clippingMaxRect;
    }
}

- (void)setIsClipping:(BOOL)isClipping
{
    [self setIsClipping:isClipping animated:NO];
}
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated
{
    _isClipping = isClipping;
    if (isClipping) {
        /** 动画切换 */
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                CGRect rect = CGRectInset(self.frame , 20, 50);
                self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, rect);
            } completion:^(BOOL finished) {
                /** 显示多余部分 */
                self.clippingView.clipsToBounds = NO;
            }];
            [UIView animateWithDuration:0.25f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.gridView.alpha = 1.f;
            } completion:nil];
        } else {
            CGRect rect = CGRectInset(self.frame , 20, 50);
            self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, rect);
            self.gridView.alpha = 1.f;
            /** 显示多余部分 */
            self.clippingView.clipsToBounds = NO;
        }
    } else {
        /** 重置最大缩放 */
        if (animated) {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
            [UIView animateWithDuration:0.1f animations:^{
                self.gridView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25f animations:^{
                    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.frame);
                    self.clippingRect = cropRect;
                }];
            }];
        } else {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
            self.gridView.alpha = 0.f;
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.frame);
            self.clippingRect = cropRect;
        }
    }
}

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated
{
    _isClipping = NO;
    /** 剪裁多余部分 */
    self.clippingView.clipsToBounds = YES;
    if (animated) {
        [UIView animateWithDuration:0.1f animations:^{
            self.gridView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f animations:^{
                [self cancel];
            }];
        }];
    } else {
        [self cancel];
    }
}

- (void)cancel
{
    [self.clippingView cancel];
    self.gridView.gridRect = self.clippingView.frame;
    self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + kMaxZoomScale - kMaxZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), kMaxZoomScale);
}

/** 还原 */
- (void)reset
{
    if (_isClipping) {
        [self.clippingView reset];
    }
}

- (BOOL)canReset
{
    if (_isClipping) {
        return self.clippingView.canReset;
    }
    return NO;
}

/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate
{
    if (_isClipping) {
        [self.clippingView rotateClockwise:YES];
    }
}

/** 创建编辑图片 */
- (UIImage *)createEditImage
{
    CGFloat zoomScale = self.zoomScale;
    [self setZoomScale:1.f];
    UIImage *image = [self.clipZoomView captureImageAtFrame:self.clippingView.frame];
    [self setZoomScale:zoomScale];
    
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    CGFloat imageWidth = CGImageGetWidth(self.image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(self.image.CGImage);
    
    if (imageWidth > width && imageHeight > height) {
        return [image scaleToSize:CGSizeMake(imageWidth, imageHeight)];
    }
    return image;
}

#pragma mark - LFClippingViewDelegate
- (void (^)(CGRect))lf_clippingViewWillBeginZooming:(LFClippingView *)clippingView
{
    __weak typeof(self) weakSelf = self;
    void (^block)(CGRect) = ^(CGRect rect){
        if (clippingView.isReseting || clippingView.isRotating) { /** 重置/旋转 需要将遮罩显示也重置 */
            [weakSelf.gridView setGridRect:rect maskLayer:YES animated:YES];
        } else {
            [weakSelf.gridView setGridRect:rect animated:YES];
        }
    };
    return block;
}
- (void)lf_clippingViewDidEndZooming:(LFClippingView *)clippingView
{
    __weak typeof(self) weakSelf = self;
    self.maskViewBlock = lf_dispatch_block_t(0.25f, ^{
        weakSelf.gridView.showMaskLayer = YES;
    });
    
    if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidEndZooming:)]) {
        [self.clippingDelegate lf_EditingViewDidEndZooming:self];
    }
}

- (void)lf_clippingViewWillBeginDragging:(LFClippingView *)clippingView
{
    /** 移动开始，隐藏 */
    self.gridView.showMaskLayer = NO;
    lf_me_dispatch_cancel(self.maskViewBlock);
}
- (void)lf_clippingViewDidEndDecelerating:(LFClippingView *)clippingView
{
    /** 移动结束，显示 */
    __weak typeof(self) weakSelf = self;
    self.maskViewBlock = lf_dispatch_block_t(0.25f, ^{
        weakSelf.gridView.showMaskLayer = YES;
    });
    if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewEndDecelerating:)]) {
        [self.clippingDelegate lf_EditingViewEndDecelerating:self];
    }
}

#pragma mark - LFGridViewDelegate
- (void)lf_gridViewDidBeginResizing:(LFGridView *)gridView
{
    gridView.showMaskLayer = NO;
    lf_me_dispatch_cancel(self.maskViewBlock);
}
- (void)lf_gridViewDidResizing:(LFGridView *)gridView
{
    /** 放大 */
    [self.clippingView zoomInToRect:gridView.gridRect];
}
- (void)lf_gridViewDidEndResizing:(LFGridView *)gridView
{
    /** 缩小 */
    [self.clippingView zoomOutToRect:gridView.gridRect];
    /** 让clippingView的动画回调后才显示showMaskLayer */
    //    self.gridView.showMaskLayer = YES;
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.clipZoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self refreshImageZoomViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    /** 重置contentSize */
    CGRect realClipZoomRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.clipZoomView.frame);
    CGFloat width = MAX(self.frame.size.width, realClipZoomRect.size.width);
    CGFloat height = MAX(self.frame.size.height, realClipZoomRect.size.height);
    CGFloat diffWidth = (width-self.clipZoomView.frame.size.width)/2;
    CGFloat diffHeight = (height-self.clipZoomView.frame.size.height)/2;
    self.contentInset = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.contentSize = CGSizeMake(width, height);
}


#pragma mark - 重写父类方法

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) { /** 非自身子视图 */
        if (event.allTouches.count == 2) { /** 2个手指 */
            return NO;
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) { /** 非自身子视图 */
        return NO;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (!self.isClipping && (self.clippingView == view || self.clipZoomView == view)) { /** 非编辑状态，改变触发响应最顶层的scrollView */
        return self;
    } else if (self.isClipping && (view == self || self.clipZoomView == view)) {
        return self.clippingView;
    }
    return view;
}

#pragma mark - Private
- (void)refreshImageZoomViewCenter {
    CGFloat offsetX = (self.width > self.contentSize.width) ? ((self.width - self.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.height > self.contentSize.height) ? ((self.height - self.contentSize.height) * 0.5) : 0.0;
    self.clipZoomView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
}

#pragma mark - LFEditingProtocol

- (void)setEditDelegate:(id<LFPhotoEditDelegate>)editDelegate
{
    self.clippingView.editDelegate = editDelegate;
}
- (id<LFPhotoEditDelegate>)editDelegate
{
    return self.clippingView.editDelegate;
}

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable
{
    [self.clippingView photoEditEnable:enable];
}

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    return self.clippingView.photoEditData;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    self.clippingView.photoEditData = photoEditData;
    self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + kMaxZoomScale - kMaxZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), kMaxZoomScale);
}

#pragma mark - 绘画功能
/** 启用绘画功能 */
- (void)setDrawEnable:(BOOL)drawEnable
{
    self.clippingView.drawEnable = drawEnable;
}
- (BOOL)drawEnable
{
    return self.clippingView.drawEnable;
}

- (BOOL)drawCanUndo
{
    return [self.clippingView drawCanUndo];
}
- (void)drawUndo
{
    [self.clippingView drawUndo];
}
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color
{
    [self.clippingView setDrawColor:color];
}

#pragma mark - 贴图功能
/** 取消激活贴图 */
- (void)stickerDeactivated
{
    [self.clippingView stickerDeactivated];
}
- (void)activeSelectStickerView
{
    [self.clippingView activeSelectStickerView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    [self.clippingView removeSelectStickerView];
}
/** 获取选中贴图的内容 */
- (LFText *)getSelectStickerText
{
    return [self.clippingView getSelectStickerText];
}
/** 更改选中贴图内容 */
- (void)changeSelectStickerText:(LFText *)text
{
    [self.clippingView changeSelectStickerText:text];
}

/** 创建贴图 */
- (void)createStickerImage:(UIImage *)image
{
    [self.clippingView createStickerImage:image];
}

#pragma mark - 文字功能
/** 创建文字 */
- (void)createStickerText:(LFText *)text
{
    [self.clippingView createStickerText:text];
}

#pragma mark - 模糊功能
/** 启用模糊功能 */
- (void)setSplashEnable:(BOOL)splashEnable
{
    self.clippingView.splashEnable = splashEnable;
}
- (BOOL)splashEnable
{
    return self.clippingView.splashEnable;
}
/** 是否可撤销 */
- (BOOL)splashCanUndo
{
    return [self.clippingView splashCanUndo];
}
/** 撤销模糊 */
- (void)splashUndo
{
    [self.clippingView splashUndo];
}

- (void)setSplashState:(BOOL)splashState
{
    self.clippingView.splashState = splashState;
}

- (BOOL)splashState
{
    return self.clippingView.splashState;
}

@end
