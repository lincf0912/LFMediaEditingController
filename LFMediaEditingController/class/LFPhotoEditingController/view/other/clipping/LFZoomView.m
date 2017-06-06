//
//  LFZoomView.m
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/8.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFZoomView.h"

@interface LFZoomView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *zoomingView;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation LFZoomView

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
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.clipsToBounds = NO;
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 5.0f;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    zoomingView.backgroundColor = [UIColor clearColor];
//    zoomingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:zoomingView];
    self.zoomingView = zoomingView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    imageView.backgroundColor = [UIColor clearColor];
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.zoomingView addSubview:imageView];
    self.imageView = imageView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self.imageView setImage:image];
}

- (void)setEditRect:(CGRect)editRect
{
    _editRect = editRect;
}

- (void)setCropRect:(CGRect)cropRect
{
    self.scrollView.frame = cropRect;
    [self.scrollView setZoomScale:1.f];
    [self.scrollView setContentSize:cropRect.size];
    [self.scrollView setContentOffset:CGPointZero];
    
    self.zoomingView.frame = self.scrollView.bounds;
    self.imageView.frame = self.zoomingView.bounds;
}

- (BOOL)isMaxZoom
{
    return self.scrollView.zoomScale == self.scrollView.maximumZoomScale;
}

- (CGRect)cappedCropRectInImageRectWithCropRect:(CGRect)cropRect
{
    CGRect rect = [self convertRect:cropRect toView:self.scrollView];
    if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame)) {
        cropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.width = CGRectGetMaxX(rect);
    }
    if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame)) {
        cropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.height = CGRectGetMaxY(rect);
    }
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame)) {
        cropRect.size.width = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(cropRect);
    }
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame)) {
        cropRect.size.height = CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(cropRect);
    }
    
    return cropRect;
}

#pragma mark 放大到指定坐标
- (void)zoomInToRect:(CGRect)toRect
{
//    CGRect rect = self.scrollView.frame;
//    if (CGRectGetWidth(toRect) > CGRectGetWidth(self.zoomingView.frame)) {
//        rect.size.width = CGRectGetWidth(toRect);
//    }
//    if (CGRectGetHeight(toRect) > CGRectGetHeight(self.zoomingView.frame)) {
//        rect.size.height = CGRectGetHeight(toRect);
//    }
//    
//    /** 比例放大zoomingView */
//    CGFloat width = CGRectGetWidth(rect);
//    CGFloat height = CGRectGetHeight(rect);
//    CGFloat scale = MAX(width / CGRectGetWidth(self.scrollView.frame), height / CGRectGetHeight(self.scrollView.frame));
//    /** 计算缩放比例 */
//    CGFloat zoomScale = MAX(self.scrollView.zoomScale * scale, 1.f);
//    
//    if (CGRectGetHeight(toRect) > CGRectGetHeight(self.zoomingView.frame) || CGRectGetWidth(toRect) > CGRectGetWidth(self.zoomingView.frame)) {
//        /** 计算偏移值 */
//        CGPoint contentOffset = self.scrollView.contentOffset;
//        
//        self.scrollView.frame = rect;
//        [self.scrollView setZoomScale:zoomScale];
//        contentOffset.x += (self.scrollView.contentOffset.x - contentOffset.x)/2;
//        contentOffset.y += (self.scrollView.contentOffset.y - contentOffset.y)/2;
//        [self.scrollView setContentOffset:contentOffset];
//    }
//    self.scrollView.minimumZoomScale = zoomScale;
}

#pragma mark 缩小到指定坐标
- (void)zoomOutToRect:(CGRect)toRect
{
    CGRect rect = [self cappedCropRectInImageRectWithCropRect:toRect];
    
    if (CGRectEqualToRect(self.scrollView.frame, rect)) {
        /** 仍然需要回调 */
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if ([self.delegate respondsToSelector:@selector(lf_zoomViewWillBeginZooming:)]) {
                                 void (^block)() = [self.delegate lf_zoomViewWillBeginZooming:self];
                                 if (block) block(self.scrollView.frame);
                             }
                         } completion:^(BOOL finished) {
                             if ([self.delegate respondsToSelector:@selector(lf_zoomViewDidEndZooming:)]) {
                                 [self.delegate lf_zoomViewDidEndZooming:self];
                             }
                         }];
        return;
    }
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editRect) / width, CGRectGetHeight(self.editRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    /** 特殊图片计算 比例100:1 或 1:100 的情况 */
    scaledWidth = MIN(scaledWidth, CGRectGetWidth(self.zoomingView.frame));
    scaledHeight = MIN(scaledHeight, CGRectGetHeight(self.zoomingView.frame));
    
    /** 计算实际显示坐标 */
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);
    
    /** 获取相对坐标 */
    CGRect zoomRect = [self convertRect:rect toView:self.zoomingView];
    
    /** 计算缩放比例 */
    CGFloat zoomScale = MIN(self.scrollView.zoomScale * scale, self.scrollView.maximumZoomScale);
    
    /** 计算偏移值 */
    __block CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.x = zoomRect.origin.x * zoomScale;
    contentOffset.y = zoomRect.origin.y * zoomScale;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.frame = cropRect;
                         [self.scrollView setZoomScale:zoomScale];
                         /** 超出最大限度Y值，调整到临界值 */
                         if (self.scrollView.contentSize.height-contentOffset.y < CGRectGetHeight(cropRect)) {
                             contentOffset.y = self.scrollView.contentSize.height-CGRectGetHeight(cropRect);
                         }
                         /** 超出最大限度X值，调整到临界值 */
                         if (self.scrollView.contentSize.width-contentOffset.x < CGRectGetWidth(cropRect)) {
                             contentOffset.x = self.scrollView.contentSize.width-CGRectGetWidth(cropRect);
                         }
                         [self.scrollView setContentOffset:contentOffset];

                         if ([self.delegate respondsToSelector:@selector(lf_zoomViewWillBeginZooming:)]) {
                             void (^block)() = [self.delegate lf_zoomViewWillBeginZooming:self];
                             if (block) block(cropRect);
                         }
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(lf_zoomViewDidEndZooming:)]) {
                             [self.delegate lf_zoomViewDidEndZooming:self];
                         }
                     }];
}

/** 截图 */
- (UIImage *)captureImage
{
    UIImage* image = nil;
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(self.scrollView.frame.size, NO, 0);
    //2.绘制图层
    [self.scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
    //3.从上下文中获取新图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    
    if (image != nil)
    {
        return image;
    }
    
    return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return self.scrollView;
    }
    return view;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(lf_zoomViewWillBeginDragging:)]) {
        [self.delegate lf_zoomViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if ([self.delegate respondsToSelector:@selector(lf_zoomViewDidEndDecelerating:)]) {
            [self.delegate lf_zoomViewDidEndDecelerating:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(lf_zoomViewDidEndDecelerating:)]) {
        [self.delegate lf_zoomViewDidEndDecelerating:self];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    /** 手动缩放后 计算是否最小值小于当前选择框范围内 */
    if (CGRectGetWidth(self.zoomingView.frame) < CGRectGetWidth(self.scrollView.frame) || CGRectGetHeight(self.zoomingView.frame) < CGRectGetHeight(self.scrollView.frame)) {
        CGRect rect = self.scrollView.frame;
        rect.size.width = MIN(CGRectGetWidth(self.zoomingView.frame), CGRectGetWidth(self.scrollView.frame));
        rect.size.height = MIN(CGRectGetHeight(self.zoomingView.frame), CGRectGetHeight(self.scrollView.frame));
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.scrollView.frame = rect;
                             self.scrollView.center = self.center;
                             if ([self.delegate respondsToSelector:@selector(lf_zoomViewWillBeginZooming:)]) {
                                 void (^block)() = [self.delegate lf_zoomViewWillBeginZooming:self];
                                 if (block) block(self.scrollView.frame);
                             }
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint contentOffset = scrollView.contentOffset;
    *targetContentOffset = contentOffset;
}

@end
