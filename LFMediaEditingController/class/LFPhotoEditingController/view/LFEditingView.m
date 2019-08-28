//
//  LFEditingView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/10.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFEditingView.h"
#import "LFGridView.h"
#import "LFGridView+private.h"
#import "LFClippingView.h"

#import "UIView+LFMEFrame.h"
#import "LFMECancelBlock.h"
#import "UIView+LFMECommon.h"
#import "UIImage+LFMECommon.h"

#import <AVFoundation/AVFoundation.h>

#define kMaxZoomScale 2.5f

#define kClipZoom_margin 20.f

CGFloat const lf_editingView_drawLineWidth = 5.f;
CGFloat const lf_editingView_splashWidth = 15.f;
CGFloat const lf_editingView_paintWidth = 50.f;
CGFloat const lf_editingView_stickMinScale = .2f;
CGFloat const lf_editingView_stickMaxScale = 3.f;

typedef NS_ENUM(NSUInteger, LFEditingViewOperation) {
    LFEditingViewOperationNone = 0,
    LFEditingViewOperationDragging = 1 << 0,
    LFEditingViewOperationZooming = 1 << 1,
    LFEditingViewOperationGridResizing = 1 << 2,
};

NSString *const kLFEditingViewData = @"LFClippingViewData";

NSString *const kLFEditingViewData_gridView_aspectRatio = @"kLFEditingViewData_gridView_aspectRatio";

NSString *const kLFEditingViewData_clippingView = @"kLFEditingViewData_clippingView";

@interface LFEditingView () <UIScrollViewDelegate, LFClippingViewDelegate, LFGridViewDelegate>

@property (nonatomic, weak) LFClippingView *clippingView;
@property (nonatomic, weak) LFGridView *gridView;
/** 因为LFClippingView需要调整transform属性，需要额外创建一层进行缩放处理，理由：UIScrollView的缩放会自动重置transform */
@property (nonatomic, weak) UIView *clipZoomView;

/** 剪裁尺寸, CGRectInset(self.bounds, 20, 50) */
@property (nonatomic, assign) CGRect clippingRect;

/** 显示图片剪裁像素 */
@property (nonatomic, weak) UILabel *imagePixel;

/** 图片像素参照坐标 */
@property (nonatomic, assign) CGSize referenceSize;

/* 底部栏高度 默认44 */
@property (nonatomic, assign) CGFloat editToolbarDefaultHeight;

@property (nonatomic, copy) lf_me_dispatch_cancelable_block_t maskViewBlock;

/** 编辑操作次数记录-有3种编辑操作 拖动、缩放、网格 并且可以同时触发任意2种，避免多次回调代理 */
@property (nonatomic, assign) LFEditingViewOperation editedOperation;

/** 默认最大化缩放 */
@property (nonatomic, assign) CGFloat defaultMaximumZoomScale;

/** 真实的图片尺寸 */
@property (nonatomic, assign) CGSize imageSize;

/** 默认长宽比例，执行一次 */
@property (nonatomic, assign) NSInteger onceDefaultAspectRatioIndex;

/** 记录剪裁前的数据 */
@property (nonatomic, assign) LFGridViewAspectRatioType old_aspectRatio;

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
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.clipsToBounds = YES;
    /** 缩放 */
    self.maximumZoomScale = kMaxZoomScale;
    self.minimumZoomScale = 1.0;
    _editToolbarDefaultHeight = 44.f;
    _defaultMaximumZoomScale = kMaxZoomScale;
    
    /** 创建缩放层，避免直接缩放LFClippingView，会改变其transform */
    UIView *clipZoomView = [[UIView alloc] initWithFrame:self.bounds];
    clipZoomView.backgroundColor = [UIColor clearColor];
    [self addSubview:clipZoomView];
    self.clipZoomView = clipZoomView;
    
    /** 创建剪裁层 */
    LFClippingView *clippingView = [[LFClippingView alloc] initWithFrame:self.bounds];
    clippingView.clippingDelegate = self;
    [self.clipZoomView addSubview:clippingView];
    self.clippingView = clippingView;
    
    LFGridView *gridView = [[LFGridView alloc] initWithFrame:self.bounds];
    gridView.delegate = self;
    /** 先隐藏剪裁网格 */
    gridView.alpha = 0.f;
    [self addSubview:gridView];
    self.gridView = gridView;
    
    self.clippingMinSize = CGSizeMake(80, 80);
    self.clippingMaxRect = [self refer_clippingRect];
    
    /** 创建显示图片像素控件 */
    UILabel *imagePixel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width-40, 30)];
    imagePixel.numberOfLines = 1;
    imagePixel.textAlignment = NSTextAlignmentCenter;
    imagePixel.font = [UIFont boldSystemFontOfSize:13.f];
    imagePixel.textColor = [UIColor whiteColor];
    imagePixel.highlighted = YES;
    imagePixel.highlightedTextColor = [UIColor whiteColor];
    imagePixel.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePixel.layer.shadowOpacity = 1.f;
    imagePixel.layer.shadowOffset = CGSizeMake(0, 0);
    imagePixel.layer.shadowRadius = 8;
    imagePixel.alpha = 0.f;
    [self addSubview:imagePixel];
    self.imagePixel = imagePixel;
    
    
    [self setSubViewData];
    
}

- (UIEdgeInsets)refer_clippingInsets
{
    CGFloat top = kClipZoom_margin;
    CGFloat left = kClipZoom_margin;
    CGFloat bottom = self.editToolbarDefaultHeight + kClipZoom_margin;
    CGFloat right = kClipZoom_margin;
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGRect)refer_clippingRect
{
    UIEdgeInsets insets = [self refer_clippingInsets];
    
    CGRect referRect = self.bounds;
    referRect.origin.x += insets.left;
    referRect.origin.y += insets.top;
    referRect.size.width -= (insets.left+insets.right);
    referRect.size.height -= (insets.top+insets.bottom);
    
    return referRect;
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image durations:nil];
}
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations
{
    _image = image;
    if (image) {
        _imageSize = image.size;
        CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.imageSize, self.bounds);
        self.gridView.controlSize = cropRect.size;
        self.gridView.gridRect = cropRect;
        self.gridView.aspectRatioHorizontally = (self.imageSize.width > self.imageSize.height);
        self.imagePixel.center = CGPointMake(CGRectGetMidX(cropRect), CGRectGetMidY(cropRect));
        /** 调整最大缩放比例 */
        {
            if (cropRect.size.width < cropRect.size.height) {
                self.defaultMaximumZoomScale = self.frame.size.width * kMaxZoomScale / cropRect.size.width;
            } else {
                self.defaultMaximumZoomScale = self.frame.size.height * kMaxZoomScale / cropRect.size.height;
            }
            self.maximumZoomScale = self.defaultMaximumZoomScale;
            
            /** 调整贴图的缩放比例 */
            CGFloat diffScale = kMaxZoomScale / self.defaultMaximumZoomScale;
            [self setStickerMinScale:(lf_editingView_stickMinScale * diffScale)];
            [self setStickerMaxScale:(lf_editingView_stickMaxScale * diffScale)];
        }
    }
    [self.clippingView setImage:image durations:durations];
    
    
    /** 计算图片像素参照坐标 */
    self.referenceSize = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.clippingMaxRect).size;
    
    /** 针对长图的展示 */
    [self fixedLongImage];
}

- (void)setClippingRect:(CGRect)clippingRect
{
    if (self.isClipping) {
        CGFloat clippingMinY = CGRectGetMinY(self.clippingMaxRect);
        if (clippingRect.origin.y < clippingMinY) {
            clippingRect.origin.y = clippingMinY;
        }
        CGFloat clippingMaxY = CGRectGetMaxY(self.clippingMaxRect);
        if (CGRectGetMaxY(clippingRect) > clippingMaxY) {
            clippingRect.size.height = self.clippingMaxRect.size.height;
        }
        CGFloat clippingMinX = CGRectGetMinX(self.clippingMaxRect);
        if (clippingRect.origin.x < clippingMinX) {
            clippingRect.origin.x = clippingMinX;
        }
        CGFloat clippingMaxX = CGRectGetMaxX(self.clippingMaxRect);
        if (CGRectGetMaxX(clippingRect) > clippingMaxX) {
            clippingRect.size.width = self.clippingMaxRect.size.width;
        }
        
        /** 调整最小尺寸 */
        CGSize clippingMinSize = self.clippingMinSize;
        if (clippingMinSize.width > clippingRect.size.width) {
            clippingMinSize.width = clippingRect.size.width;
        }
        if (clippingMinSize.height > clippingRect.size.height) {
            clippingMinSize.height = clippingRect.size.height;
        }
        self.clippingMinSize = clippingMinSize;
    }
    _clippingRect = clippingRect;
    self.gridView.gridRect = clippingRect;
    UIEdgeInsets insets = [self refer_clippingInsets];
    /** 计算clippingView与父界面的中心偏差坐标 */
    self.clippingView.offsetSuperCenter = self.isClipping ? CGPointMake(insets.right-insets.left, insets.bottom-insets.top) : CGPointZero;
    self.clippingView.cropRect = clippingRect;
    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
}

- (void)setClippingMinSize:(CGSize)clippingMinSize
{
    if (CGSizeEqualToSize(CGSizeZero, _clippingMinSize) || (clippingMinSize.width < CGRectGetWidth(_clippingMaxRect) && clippingMinSize.height < CGRectGetHeight(_clippingMaxRect))) {
        
        CGSize normalClippingMinSize = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, [self refer_clippingRect]).size;
        /** 需要考虑到旋转后到尺寸可能会更加小，取最小值 */
        CGSize rotateClippingMinSize = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(self.clippingView.size.height, self.clippingView.size.width), [self refer_clippingRect]).size;
        
        CGSize newClippingMinSize = CGSizeMake(MIN(normalClippingMinSize.width, rotateClippingMinSize.width), MIN(normalClippingMinSize.height, rotateClippingMinSize.height));
        {
            if (clippingMinSize.width > newClippingMinSize.width) {
                clippingMinSize.width = newClippingMinSize.width;
            }
            if (clippingMinSize.height > newClippingMinSize.height) {
                clippingMinSize.height = newClippingMinSize.height;
            }
        }
        
        _clippingMinSize = clippingMinSize;
        self.gridView.controlMinSize = clippingMinSize;
    }
}

- (void)setClippingMaxRect:(CGRect)clippingMaxRect
{
    if (CGRectEqualToRect(CGRectZero, _clippingMaxRect) || (CGRectGetWidth(clippingMaxRect) > _clippingMinSize.width && CGRectGetHeight(clippingMaxRect) > _clippingMinSize.height)) {
        
        CGRect newClippingMaxRect = [self refer_clippingRect];
        
        if (clippingMaxRect.origin.y < newClippingMaxRect.origin.y) {
            clippingMaxRect.origin.y = newClippingMaxRect.origin.y;
        }
        if (clippingMaxRect.origin.x < newClippingMaxRect.origin.x) {
            clippingMaxRect.origin.x = newClippingMaxRect.origin.x;
        }
        if (CGRectGetMaxY(clippingMaxRect) > CGRectGetMaxY(newClippingMaxRect)) {
            clippingMaxRect.size.height = newClippingMaxRect.size.height;
        }
        if (CGRectGetMaxX(clippingMaxRect) > CGRectGetMaxX(newClippingMaxRect)) {
            clippingMaxRect.size.width = newClippingMaxRect.size.width;
        }
        
        _clippingMaxRect = clippingMaxRect;
        self.gridView.controlMaxRect = clippingMaxRect;
        self.clippingView.editRect = clippingMaxRect;
        /** 计算缩放剪裁尺寸 */
        self.referenceSize = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.clippingMaxRect).size;
    }
}

- (void)setClipping:(BOOL)clipping
{
    [self setClipping:clipping animated:NO];
}
- (void)setClipping:(BOOL)clipping animated:(BOOL)animated
{
    if (!self.image) {
        /** 没有图片禁止开启编辑模式 */
        return;
    }
    self.editedOperation = LFEditingViewOperationNone;
    _clipping = clipping;
    self.clippingView.useGesture = clipping;
    
    self.old_aspectRatio = self.gridView.aspectRatio;
    if (self.onceDefaultAspectRatioIndex && clipping) {
        self.old_aspectRatio = self.onceDefaultAspectRatioIndex;
    }
    
//    BOOL isCircle = self.old_aspectRatio == LFGridViewAspectRatioType_Circle;
    if (clipping) {
        if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillAppearClip:)]) {
            [self.clippingDelegate lf_EditingViewWillAppearClip:self];
        }
    } else {
        if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillDisappearClip:)]) {
            [self.clippingDelegate lf_EditingViewWillDisappearClip:self];
        }
    }
    
    
    if (clipping) {
        [UIView animateWithDuration:(animated ? 0.125f : 0) animations:^{
            [self setZoomScale:self.minimumZoomScale];
            /** 关闭缩放 */
            self.maximumZoomScale = self.minimumZoomScale;
            /** 重置contentSize */
            [self resetContentSize];
        }];
    } else {
        self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + self.defaultMaximumZoomScale - self.defaultMaximumZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), self.defaultMaximumZoomScale);
    }
    
    if (clipping) {
        /** 动画切换 */
        if (animated) {
            
            /** 判断是否需要调整长宽比例 */
            BOOL changedAspectRatio = !CGRectEqualToRect(self.gridView.gridRect, self.clippingView.frame);
            
            if (changedAspectRatio) {
                /** 调整长宽比例过程会对遮罩隐藏和显示，避免遮罩闪烁。 */
                self.gridView.showMaskLayer = NO;
            }
            [UIView animateWithDuration:0.25f animations:^{
                self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, [self refer_clippingRect]);
//                if (isCircle) {
//                    [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(self.clippingRect)/2];
//                }
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25f animations:^{
                    self.gridView.alpha = 1.f;
                    self.imagePixel.alpha = 1.f;
                } completion:^(BOOL finished) {
//                    if (isCircle) {
//                        [self.clippingView LFME_setCornerRadiusWithoutMasks:0];
//                    }
                    /** 显示多余部分 */
                    self.clippingView.clipsToBounds = NO;

                    if (self.onceDefaultAspectRatioIndex) {
                        /** 代理优先执行，下面可能是编辑操作，gridView.gridRect会发生改变，影响计算结果 */
                        if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidAppearClip:)]) {
                            [self.clippingDelegate lf_EditingViewDidAppearClip:self];
                        }
                        [self.gridView setAspectRatio:self.onceDefaultAspectRatioIndex animated:YES];
                        self.onceDefaultAspectRatioIndex = 0;
                    } else {
                        /** 处理缩放比例 */
                        [self lf_gridViewDidAspectRatio:self.gridView];
                        /** 代理延迟执行，因为gridView.gridRect并没有发生改变，等待clippingView的大小调整后触发 */
                        if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidAppearClip:)]) {
                            [self.clippingDelegate lf_EditingViewDidAppearClip:self];
                        }
                    }
                }];
            }];
        } else {
            self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, [self refer_clippingRect]);
//            if (isCircle) {
//                [self.clippingView LFME_setCornerRadiusWithoutMasks:0];
//            }
            self.gridView.alpha = 1.f;
            self.imagePixel.alpha = 1.f;
            /** 显示多余部分 */
            self.clippingView.clipsToBounds = NO;
            
            if (self.onceDefaultAspectRatioIndex) {
                if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidAppearClip:)]) {
                    [self.clippingDelegate lf_EditingViewDidAppearClip:self];
                }
                [self.gridView setAspectRatio:self.onceDefaultAspectRatioIndex animated:YES];
                self.onceDefaultAspectRatioIndex = 0;
            } else {
                /** 处理缩放比例 */
                [self lf_gridViewDidAspectRatio:self.gridView];
                if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidAppearClip:)]) {
                    [self.clippingDelegate lf_EditingViewDidAppearClip:self];
                }
            }
        }
        [self updateImagePixelText];
    } else {
        /** 重置最大缩放 */
        if (animated) {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
//            if (isCircle) {
//                [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(self.clippingRect)/2];
//            }
            [UIView animateWithDuration:0.1f animations:^{
                self.gridView.alpha = 0.f;
                self.imagePixel.alpha = 0.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25f animations:^{
                    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.bounds);
                    self.clippingRect = cropRect;
//                    if (isCircle) {
//                        [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(cropRect)/2];
//                    }
                }];
                
                [UIView animateWithDuration:0.125f delay:0.125f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    /** 针对长图的展示 */
                    [self fixedLongImage];
                } completion:^(BOOL finished) {
                    if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidDisappearClip:)]) {
                        [self.clippingDelegate lf_EditingViewDidDisappearClip:self];
                    }
                }];
                
            }];
        } else {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
            self.gridView.alpha = 0.f;
            self.imagePixel.alpha = 0.f;
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.bounds);
//            if (isCircle) {
//                [self.clippingView LFME_setCornerRadius:CGRectGetMidX(cropRect)];
//            }
            self.clippingRect = cropRect;
            /** 针对长图的展示 */
            [self fixedLongImage];
            if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidDisappearClip:)]) {
                [self.clippingDelegate lf_EditingViewDidDisappearClip:self];
            }
        }
    }
}

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated
{
    self.editedOperation = LFEditingViewOperationNone;
    _clipping = NO;
    self.clippingView.useGesture = _clipping;
//    BOOL isCircle = self.old_aspectRatio == LFGridViewAspectRatioType_Circle;
    if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillDisappearClip:)]) {
        [self.clippingDelegate lf_EditingViewWillDisappearClip:self];
    }
    
    /** 剪裁多余部分 */
    self.clippingView.clipsToBounds = YES;
    if (animated) {
        [UIView animateWithDuration:0.1f animations:^{
            self.gridView.alpha = 0.f;
            self.imagePixel.alpha = 0.f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f animations:^{
                [self cancel];
//                if (isCircle) {
//                    [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(self.clippingRect)/2];
//                }
            }];
            [UIView animateWithDuration:0.125f delay:0.125f options:UIViewAnimationOptionCurveEaseOut animations:^{
                /** 针对长图的展示 */
                [self fixedLongImage];
            } completion:^(BOOL finished) {
                if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidDisappearClip:)]) {
                    [self.clippingDelegate lf_EditingViewDidDisappearClip:self];
                }
            }];
        }];
    } else {
        [self cancel];
//        if (isCircle) {
//            [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(self.clippingRect)/2];
//        }
        /** 针对长图的展示 */
        [self fixedLongImage];
        if ([self.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidDisappearClip:)]) {
            [self.clippingDelegate lf_EditingViewDidDisappearClip:self];
        }
    }
}

- (void)cancel
{
    [self.clippingView cancel];
    _clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.bounds);
    self.gridView.gridRect = self.clippingView.frame;
    [self.gridView setAspectRatioWithoutDelegate:self.old_aspectRatio];
    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
    self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + self.defaultMaximumZoomScale - self.defaultMaximumZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), self.defaultMaximumZoomScale);
}

/** 还原 */
- (void)reset
{
    if (self.isClipping) {
        /** 若可以调整长宽比例，则重置它，否则保留默认值 */
        [self setAspectRatioIndex:0];
        if (self.fixedAspectRatio) {
            [self.clippingView resetToRect:self.gridView.gridRect];
        } else {
            [self.clippingView reset];            
        }
    }
}

- (BOOL)canReset
{
    if (self.isClipping) {
        if (self.fixedAspectRatio) {
            return [self.clippingView canResetWithRect:self.gridView.gridRect];
        } else {
            return self.clippingView.canReset;
        }
    }
    return NO;
}

/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate
{
    if (self.isClipping) {
        [self.clippingView rotateClockwise:YES];
    }
}

/** 默认长宽比例 */
- (void)setDefaultAspectRatioIndex:(NSUInteger)defaultAspectRatioIndex
{
    _defaultAspectRatioIndex = defaultAspectRatioIndex;
    _onceDefaultAspectRatioIndex = defaultAspectRatioIndex;
}

/** 长宽比例 */
- (void)setAspectRatioIndex:(NSUInteger)aspectRatioIndex
{
    if (self.fixedAspectRatio) return;
    self.onceDefaultAspectRatioIndex = 0;
    [self.gridView setAspectRatio:(LFGridViewAspectRatioType)aspectRatioIndex];
}

- (NSArray <NSString *>*)aspectRatioDescs
{
    if (self.fixedAspectRatio) nil;
    return [self.gridView aspectRatioDescs];
}

- (NSUInteger)aspectRatioIndex
{
    if (self.fixedAspectRatio) return 0;
    LFGridViewAspectRatioType type = self.gridView.aspectRatio;
    return (NSUInteger)type;
}

/** 补底操作-多手势同时触发时，部分逻辑没有实时处理，当手势完全停止后补充处理 */
- (void)supplementHandle
{
    if (!CGRectEqualToRect(self.gridView.gridRect, self.clippingView.frame)) {
        self.gridView.showMaskLayer = NO;
        lf_me_dispatch_cancel(self.maskViewBlock);
        [self.clippingView zoomOutToRect:self.gridView.gridRect];
    }
}

/** 创建编辑图片 */
- (void)createEditImage:(void (^)(UIImage *editImage))complete
{
    CGFloat scale = self.clippingView.zoomScale;
    CGAffineTransform trans = self.clippingView.transform;
    CGPoint contentOffset = self.clippingView.contentOffset;
    CGSize contentSize = self.clippingView.contentSize;
    CGRect clippingRect = self.clippingView.frame;
    
//    /** 参数取整，否则可能会出现1像素偏差 */
//    clippingRect.origin.x = ((int)(clippingRect.origin.x+0.5)*1.f);
//    clippingRect.origin.y = ((int)(clippingRect.origin.y+0.5)*1.f);
//    clippingRect.size.width = ((int)(clippingRect.size.width+0.5)*1.f);
//    clippingRect.size.height = ((int)(clippingRect.size.height+0.5)*1.f);
    
    CGSize size = clippingRect.size;
    
    UIImage *otherImage = nil;
    if (self.clippingView.hasZoomingViewData) {
        /** 忽略原图的显示，仅需要原图以上的编辑图层 */
        self.clippingView.imageViewHidden = YES;
        /** 获取编辑图层视图 */
        otherImage = [self.clipZoomView LFME_captureImageAtFrame:clippingRect];
        /** 恢复原图的显示 */
        self.clippingView.imageViewHidden = NO;
    }
    
    /* Return a transform which rotates by `angle' radians:
     t' = [ cos(angle) sin(angle) -sin(angle) cos(angle) 0 0 ] */
    CGFloat rotate = acosf(trans.a);
    if (trans.b < 0) {
        rotate = M_PI-asinf(trans.b);
    }
    // 将弧度转换为角度
//    CGFloat degree = rotate/M_PI * 180;
    
    __block UIImage *editImage = self.image;
    CGRect clipViewRect = self.clippingView.normalRect;
    /** UIScrollView的缩放率 * 剪裁尺寸变化比例 / 图片屏幕缩放率 */
    CGFloat clipScale = scale * (clipViewRect.size.width/(self.imageSize.width*editImage.scale));
    /** 计算被剪裁的原尺寸图片位置 */
    CGRect clipRect;
    if (fabs(trans.b) == 1.f) {
        clipRect = CGRectMake(contentOffset.x/clipScale, contentOffset.y/clipScale, size.height/clipScale, size.width/clipScale);
    } else {
        clipRect = CGRectMake(contentOffset.x/clipScale, contentOffset.y/clipScale, size.width/clipScale, size.height/clipScale);
    }
    /** 参数取整，否则可能会出现1像素偏差 */
    clipRect.origin.x = ((int)(clipRect.origin.x+0.5)*1.f);
    clipRect.origin.y = ((int)(clipRect.origin.y+0.5)*1.f);
    clipRect.size.width = ((int)(clipRect.size.width+0.5)*1.f);
    clipRect.size.height = ((int)(clipRect.size.height+0.5)*1.f);
    
    // CIImage 的原始坐标在左下角，y值需要重新计算。
    clipRect.origin.y = contentSize.height/clipScale - clipRect.size.height - clipRect.origin.y;
    
    /** 滤镜图片 */
    UIImage *showImage = [self getFilterImage];
//    BOOL isCircle = self.old_aspectRatio == LFGridViewAspectRatioType_Circle;
    BOOL isCircle = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
        /** 创建方法 */
        UIImage *(^ClipEditImage)(UIImage *) = ^UIImage * (UIImage *image) {
            /** 剪裁图片 */
            CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
            ciimage = [ciimage imageByCroppingToRect:clipRect];
            if (rotate > 0) {
                /** 调整角度 */
                CGAffineTransform t = CGAffineTransformMakeRotation(-1 * rotate);
                ciimage = [ciimage imageByApplyingTransform:t];
            }
            if (otherImage) {
                /** 与其它图层合并 */
                CIImage *ciOtherImage = [CIImage imageWithCGImage:otherImage.CGImage];
                float verticalRadio = ciimage.extent.size.height*1.0/ciOtherImage.extent.size.height;
                float horizontalRadio = ciimage.extent.size.width*1.0/ciOtherImage.extent.size.width;
                float radio = 1;
                if(verticalRadio>1 && horizontalRadio>1)
                {
                    radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
                }
                else
                {
                    radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
                }
                CGAffineTransform t = CGAffineTransformMakeScale(radio, radio);
                ciOtherImage = [ciOtherImage imageByApplyingTransform:t];
                t = CGAffineTransformMakeTranslation(ciimage.extent.origin.x-ciOtherImage.extent.origin.x, ciimage.extent.origin.y-ciOtherImage.extent.origin.y);
                ciOtherImage = [ciOtherImage imageByApplyingTransform:t];
                /** 合并图层 */
                ciimage = [ciOtherImage imageByCompositingOverImage:ciimage];
            }
            
            
            if (isCircle)
            {
                /** 画圆 */
                CGFloat radius = ciimage.extent.size.width / 2;
                NSDictionary *maskParas = @{@"inputCenter"  : [CIVector vectorWithX:radius Y:radius],
                                            @"inputRadius0" : @(radius),
                                            @"inputRadius1" : @(radius),
                                            @"inputColor0" : [CIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                            @"inputColor1" : [CIColor colorWithRed:0 green:0 blue:0 alpha:1]};
                CIImage *circle = [CIFilter filterWithName:@"CIRadialGradient"
                                       withInputParameters:maskParas].outputImage;
                
                /** 生成圆形 mask */
                CIImage *mask = [CIFilter filterWithName:@"CIMaskToAlpha"
                                     withInputParameters:@{kCIInputImageKey : circle}].outputImage;
                
                CGAffineTransform t = CGAffineTransformMakeTranslation(ciimage.extent.origin.x, ciimage.extent.origin.y);
                mask = [mask imageByApplyingTransform:t];
                
                /** 生成新的圆角的图片 */
                ciimage = [CIFilter filterWithName:@"CIBlendWithAlphaMask"
                              withInputParameters:@{kCIInputMaskImageKey : mask,
                                                    kCIInputImageKey : ciimage}].outputImage;
            }
            
            UIImage *returnedImage = nil;
            CGImageRef imageRef = [context createCGImage:ciimage fromRect:ciimage.extent];
            if (imageRef != nil) {
                returnedImage = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            return returnedImage;
        };
        
        if (showImage.images.count) {
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:showImage.images.count];
            for (UIImage *image in showImage.images) {
                UIImage *newImage = ClipEditImage(image);
                if (newImage) {
                    [images addObject:newImage];
                } else {
                    break;
                }
            }
            /** 若数量不一致，解析gif失败，生成静态图片 */
            if (images.count == showImage.images.count) {
                editImage = [UIImage animatedImageWithImages:images duration:showImage.duration];
            }
        } else {
            editImage = ClipEditImage(showImage);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *resultImage = editImage;
            
            if (!resultImage) {
                /** 合并操作有误，直接截取原始图层 */
                resultImage = [self.clipZoomView LFME_captureImageAtFrame:self.clippingView.frame];
            }
            
            if (complete) {
                complete(resultImage);
            }
        });
    });
}

#pragma mark - LFClippingViewDelegate
- (void (^)(CGRect))lf_clippingViewWillBeginZooming:(LFClippingView *)clippingView
{
    if (self.editedOperation == LFEditingViewOperationNone && [self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillBeginEditing:)]) {
        [self.clippingDelegate lf_EditingViewWillBeginEditing:self];
    }
    self.editedOperation |= LFEditingViewOperationZooming;
    
    __weak typeof(self) weakSelf = self;
    void (^block)(CGRect) = ^(CGRect rect){
        if (clippingView.isReseting || clippingView.isRotating) { /** 重置/旋转 需要将遮罩显示也重置 */
            [weakSelf.gridView setGridRect:rect maskLayer:YES animated:YES];
        } else if (clippingView.isZooming) { /** 缩放 */
            weakSelf.gridView.showMaskLayer = NO;
            lf_me_dispatch_cancel(weakSelf.maskViewBlock);
        } else {
            [weakSelf.gridView setGridRect:rect animated:YES];
        }
        
        /** 图片像素 */
        [weakSelf updateImagePixelText];
    };
    
    return block;
}
- (void)lf_clippingViewDidZoom:(LFClippingView *)clippingView
{
    if (clippingView.zooming) {
        [self updateImagePixelText];
    }
}
- (void)lf_clippingViewDidEndZooming:(LFClippingView *)clippingView
{
    if (self.editedOperation & LFEditingViewOperationZooming) {
        self.editedOperation ^= LFEditingViewOperationZooming;
    }
    __weak typeof(self) weakSelf = self;
    self.maskViewBlock = lf_dispatch_block_t(0.25f, ^{
        [weakSelf updateImagePixelText];
        
        if (weakSelf.editedOperation == LFEditingViewOperationNone) {
            if (!weakSelf.gridView.isDragging) {
                if ([weakSelf.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidEndEditing:)]) {
                    [weakSelf.clippingDelegate lf_EditingViewDidEndEditing:weakSelf];
                }
                weakSelf.gridView.showMaskLayer = YES;
            }
        }
        
    });
    
}

- (void)lf_clippingViewWillBeginDragging:(LFClippingView *)clippingView
{
    if (self.editedOperation == LFEditingViewOperationNone && [self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillBeginEditing:)]) {
        [self.clippingDelegate lf_EditingViewWillBeginEditing:self];
    }
    self.editedOperation |= LFEditingViewOperationDragging;
    /** 移动开始，隐藏 */
    self.gridView.showMaskLayer = NO;
    lf_me_dispatch_cancel(self.maskViewBlock);
}
- (void)lf_clippingViewDidEndDecelerating:(LFClippingView *)clippingView
{
    /** 移动结束，显示 */
    if (!self.gridView.isDragging && !CGRectEqualToRect(self.gridView.gridRect, self.clippingView.frame)) {
        [self supplementHandle];
        if (self.editedOperation & LFEditingViewOperationDragging) {
            self.editedOperation ^= LFEditingViewOperationDragging;
        }
    } else {
        if (self.editedOperation & LFEditingViewOperationDragging) {
            self.editedOperation ^= LFEditingViewOperationDragging;
        }
        __weak typeof(self) weakSelf = self;
        self.maskViewBlock = lf_dispatch_block_t(0.25f, ^{
            if (weakSelf.editedOperation == LFEditingViewOperationNone) {
                if (!weakSelf.gridView.isDragging) {
                    if ([weakSelf.clippingDelegate respondsToSelector:@selector(lf_EditingViewDidEndEditing:)]) {
                        [weakSelf.clippingDelegate lf_EditingViewDidEndEditing:weakSelf];
                    }
                    weakSelf.gridView.showMaskLayer = YES;
                }
            }
        });
    }
}

#pragma mark - LFGridViewDelegate
- (void)lf_gridViewDidBeginResizing:(LFGridView *)gridView
{
    if (self.editedOperation == LFEditingViewOperationNone && [self.clippingDelegate respondsToSelector:@selector(lf_EditingViewWillBeginEditing:)]) {
        [self.clippingDelegate lf_EditingViewWillBeginEditing:self];
    }
    self.editedOperation |= LFEditingViewOperationGridResizing;
    gridView.showMaskLayer = NO;
    lf_me_dispatch_cancel(self.maskViewBlock);
}
- (void)lf_gridViewDidResizing:(LFGridView *)gridView
{
    /** 放大 */
    [self.clippingView zoomInToRect:gridView.gridRect];
    
    /** 图片像素 */
    [self updateImagePixelText];
}
- (void)lf_gridViewDidEndResizing:(LFGridView *)gridView
{
    /** 缩小 */
    [self.clippingView zoomOutToRect:gridView.gridRect];
    if (self.editedOperation & LFEditingViewOperationGridResizing) {
        self.editedOperation ^= LFEditingViewOperationGridResizing;
    }
    /** 让clippingView的动画回调后才显示showMaskLayer */
    //    self.gridView.showMaskLayer = YES;
}
/** 调整长宽比例 */
- (void)lf_gridViewDidAspectRatio:(LFGridView *)gridView
{
    if (!CGRectEqualToRect(gridView.gridRect, self.clippingView.frame)) {
        self.editedOperation |= LFEditingViewOperationGridResizing;
        gridView.showMaskLayer = NO;
        lf_me_dispatch_cancel(self.maskViewBlock);
        
        /** 放大 */
        [self.clippingView zoomInToRect:gridView.gridRect];
        
        /** 图片像素 */
        [self updateImagePixelText];
        
        /** 缩小 */
        [self.clippingView zoomOutToRect:gridView.gridRect];
        if (self.editedOperation & LFEditingViewOperationGridResizing) {
            self.editedOperation ^= LFEditingViewOperationGridResizing;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.displayView setNeedsDisplay];
}


- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.clipZoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self refreshImageZoomViewCenter];
    
    [self.displayView setNeedsDisplay];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    /** 重置contentSize */
    [self resetContentSize];
}


#pragma mark - 重写父类方法

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    
//    NSLog(@"touchesShouldBegin -- %@ -- :%ld", view, event.allTouches.count );
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) { /** 非自身子视图 */
        if (event.allTouches.count == 2) { /** 2个手指 */
            return NO;
        } else {
            /** 因为关闭了手势延迟，2指缩放时，但屏幕未能及时检测到2指，导致不会进入event.allTouches.count == 2的判断，随后屏幕检测到2指，从而重新触发hitTest:withEvent:，需要重新指派正确的手势响应对象。 */
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    /**
     如果返回YES:(系统默认)是允许UIScrollView，按照消息响应链向子视图传递消息的
     如果返回NO:UIScrollView,就接收不到滑动事件了。
     */
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) {
        if ([self drawEnable] || [self splashEnable] || [self stickerEnable] ) {
            /**
             编辑视图正在编辑时，优先处理。
             这里不用条件判断，gestureRecognizer:shouldReceiveTouch:时已经对手势进行筛选了。
             */
        } else {
            /** 非自身子视图 */
            return NO;
        }
    }
    return [super touchesShouldCancelInContentView:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (!self.isClipping && (self.clippingView == view || self.clipZoomView == view)) { /** 非编辑状态，改变触发响应最顶层的scrollView */
        view = self;
    } else if (self.isClipping && (view == self || self.clipZoomView == view)) {
        view = self.clippingView;
    }
//    NSLog(@"%@", [view class]);
    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /** 解决部分机型在编辑期间会触发滑动导致无法编辑的情况 */
    if (self.isClipping) {
        /** 自身手势被触发、响应视图非自身、被触发手势为滑动手势 */
        return NO;
    } else if ([self drawEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 绘画时候，禁用滑动手势 */
        return NO;
    } else if ([self splashEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 模糊时候，禁用滑动手势 */
        return NO;
    } else if ([self stickerEnable] && ![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        /** 贴图移动时候，禁用滑动手势 */
        return NO;
    }
    return YES;
}

#pragma mark - Private
- (void)refreshImageZoomViewCenter {
    CGFloat offsetX = (self.width > self.contentSize.width) ? ((self.width - self.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.height > self.contentSize.height) ? ((self.height - self.contentSize.height) * 0.5) : 0.0;
    self.clipZoomView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
}

- (void)resetContentSize
{
    /** 重置contentSize */
    CGRect realClipZoomRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.clipZoomView.frame);
    CGFloat width = MAX(self.frame.size.width, realClipZoomRect.size.width);
    CGFloat height = MAX(self.frame.size.height, realClipZoomRect.size.height);
    CGFloat diffWidth = (width-self.clipZoomView.frame.size.width)/2;
    CGFloat diffHeight = (height-self.clipZoomView.frame.size.height)/2;
    self.contentInset = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.contentSize = CGSizeMake(width-diffWidth, height-diffHeight);
    
    [self setSubViewData];
}

- (void)setSubViewData
{
    /** 默认绘画线粗 */
    [self setDrawLineWidth:lf_editingView_drawLineWidth/self.zoomScale];
    /** 默认马赛克大小 */
    [self setSplashWidth:lf_editingView_splashWidth/self.zoomScale];
    /** 默认画笔大小 */
    [self setPaintWidth:lf_editingView_paintWidth/self.zoomScale];
    /** 屏幕缩放率 */
    [self setScreenScale:self.zoomScale];
}

- (void)fixedLongImage
{
    /** 竖图 */
//    if (self.clippingView.frame.size.width < self.frame.size.width)
    {
        /** 屏幕大小的缩放比例 */
        CGFloat zoomScale = (self.frame.size.width / self.clippingView.frame.size.width);
        [self setZoomScale:zoomScale];
        /** 保持顶部不动的放大效果 */
        CGPoint contentOffset = self.contentOffset;
        contentOffset.y = 0;
        [self setContentOffset:contentOffset];
        /** 重置contentSize */
        [self resetContentSize];
        /** 滚到顶部 */
        [self setContentOffset:CGPointMake(-self.contentInset.left, -self.contentInset.top)];
    }
}

#pragma mark - 更新图片像素
- (void)updateImagePixelText;
{
    CGFloat scale = self.clippingView.zoomScale/self.clippingView.first_minimumZoomScale;
    CGSize realSize = CGSizeMake(CGRectGetWidth(self.gridView.gridRect)/scale, CGRectGetHeight(self.gridView.gridRect)/scale);
    CGFloat screenScale = [UIScreen mainScreen].scale;
    int pixelW = (int)((self.imageSize.width*screenScale)/self.referenceSize.width*realSize.width+0.5);
    int pixelH = (int)((self.imageSize.height*screenScale)/self.referenceSize.height*realSize.height+0.5);
    self.imagePixel.text = [NSString stringWithFormat:@"%dx%d", pixelW, pixelH];
    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
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

/** 显示视图 */
- (UIView *)displayView
{
    return self.clippingView.displayView;
}

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSMutableDictionary *data = [@{} mutableCopy];
    
    if (self.gridView.aspectRatio > 0 ) {
        NSDictionary *myData = @{kLFEditingViewData_gridView_aspectRatio:@(self.gridView.aspectRatio)};
        [data setObject:myData forKey:kLFEditingViewData];
    }
    
    NSDictionary *clippingViewData = self.clippingView.photoEditData;
    if (clippingViewData) [data setObject:clippingViewData forKey:kLFEditingViewData_clippingView];
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    self.clippingView.photoEditData = photoEditData[kLFEditingViewData_clippingView];
    _clippingRect = self.clippingView.frame;
    self.gridView.gridRect = self.clippingRect;
    self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + self.defaultMaximumZoomScale - self.defaultMaximumZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), self.defaultMaximumZoomScale);
    NSDictionary *myData = photoEditData[kLFEditingViewData];
    if (myData) {
        LFGridViewAspectRatioType aspectRatio = [myData[kLFEditingViewData_gridView_aspectRatio] integerValue];
        [self.gridView setAspectRatioWithoutDelegate:aspectRatio];
        self.old_aspectRatio = aspectRatio;
//        BOOL isCircle = self.old_aspectRatio == LFGridViewAspectRatioType_Circle;
//        if (isCircle) {
//            [self.clippingView LFME_setCornerRadiusWithoutMasks:CGRectGetWidth(self.clippingRect)/2];
//        }
    }
    /** 针对长图的展示 */
    [self fixedLongImage];
}

#pragma mark - 滤镜功能
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType
{
    [self.clippingView changeFilterType:cmType];
}
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType
{
    return [self.clippingView getFilterType];
}
/** 获取滤镜图片 */
- (UIImage *)getFilterImage
{
    return [self.clippingView getFilterImage];
}

#pragma mark - 绘画功能
/** 启用绘画功能 */
- (void)setDrawEnable:(BOOL)drawEnable
{
    /** 禁止移动 */
    self.panGestureRecognizer.enabled = !drawEnable;
    self.clippingView.drawEnable = drawEnable;
}
- (BOOL)drawEnable
{
    return self.clippingView.drawEnable;
}

- (BOOL)isDrawing
{
    return self.clippingView.isDrawing;
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

/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth
{
    [self.clippingView setDrawLineWidth:lineWidth];
}

#pragma mark - 贴图功能
/** 贴图启用 */
- (BOOL)stickerEnable
{
    return [self.clippingView stickerEnable];
}
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
/** 屏幕缩放率 */
- (void)setScreenScale:(CGFloat)scale
{
    [self.clippingView setScreenScale:scale];
}
/** 最小缩放率 默认0.2 */
- (void)setStickerMinScale:(CGFloat)stickerMinScale
{
    self.clippingView.stickerMinScale = stickerMinScale;
}
- (CGFloat)stickerMinScale
{
    return self.clippingView.stickerMinScale;
}
/** 最大缩放率 默认3.0 */
- (void)setStickerMaxScale:(CGFloat)stickerMaxScale
{
    self.clippingView.stickerMaxScale = stickerMaxScale;
}
- (CGFloat)stickerMaxScale
{
    return self.clippingView.stickerMaxScale;
}
/** 创建贴图 */
- (void)createSticker:(LFStickerItem *)item
{
    [self.clippingView createSticker:item];
}
/** 获取选中贴图的内容 */
- (LFStickerItem *)getSelectSticker
{
    return [self.clippingView getSelectSticker];
}
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(LFStickerItem *)item
{
    [self.clippingView changeSelectSticker:item];
}

#pragma mark - 模糊功能
/** 启用模糊功能 */
- (void)setSplashEnable:(BOOL)splashEnable
{
    /** 禁止移动 */
    self.panGestureRecognizer.enabled = !splashEnable;
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
- (BOOL)isSplashing
{
    return self.clippingView.isSplashing;
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

/** 设置马赛克大小 */
- (void)setSplashWidth:(CGFloat)squareWidth
{
    [self.clippingView setSplashWidth:squareWidth];
}
/** 设置画笔大小 */
- (void)setPaintWidth:(CGFloat)paintWidth
{
    [self.clippingView setPaintWidth:paintWidth];
}

@end
