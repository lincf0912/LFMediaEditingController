//
//  LFEditingProtocol.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/18.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFEditingProtocol.h"
#import <objc/runtime.h>
#import "NSBundle+LFMediaEditing.h"

#import "LFDrawView.h"
#import "LFStickerView.h"

#import "LFFilterGifView.h"

#import "LFFilterDataProtocol.h"

static const char * LFEditingProtocolProtocolxecutorKey = "LFEditingProtocolProtocolxecutorKey";
static const char * LFEditingProtocolEditDelegateKey = "LFEditingProtocolEditDelegateKey";

static const char * LFEditingProtocolDrawViewKey = "LFEditingProtocolDrawViewKey";
static const char * LFEditingProtocolStickerViewKey = "LFEditingProtocolStickerViewKey";
static const char * LFEditingProtocolSplashViewKey = "LFEditingProtocolSplashViewKey";

static const char * LFEditingProtocolDisplayViewKey = "LFEditingProtocolDisplayViewKey";

static const char * LFEditingProtocolEditEnableKey = "LFEditingProtocolEditEnableKey";
static const char * LFEditingProtocolDrawViewEnableKey = "LFEditingProtocolDrawViewEnableKey";
static const char * LFEditingProtocolStickerViewEnableKey = "LFEditingProtocolStickerViewEnableKey";
static const char * LFEditingProtocolSplashViewEnableKey = "LFEditingProtocolSplashViewEnableKey";

static const char * LFEditingProtocolDrawLineWidthKey = "LFEditingProtocolDrawLineWidthKey";
static const char * LFEditingProtocolDrawLineColorKey = "LFEditingProtocolDrawLineColorKey";
static const char * LFEditingProtocolSplashLineWidthKey = "LFEditingProtocolSplashLineWidthKey";

@interface UIView (LFEditingProtocolPrivate)
/** 记录编辑层是否可控 */
@property (nonatomic, assign) BOOL lf_editEnable;
@property (nonatomic, assign) BOOL lf_drawViewEnable;
@property (nonatomic, assign) BOOL lf_stickerViewEnable;
@property (nonatomic, assign) BOOL lf_splashViewEnable;

/** 记录画笔的宽度 */
@property (nonatomic, assign) CGFloat lf_drawLineWidth;
@property (nonatomic, assign) CGFloat lf_splashLineWidth;

@end

@implementation UIView (LFEditingProtocol)

#pragma mark - property
// 协议执行者
- (UIView <LFEditingProtocol>*)lf_protocolxecutor
{
    return objc_getAssociatedObject(self, LFEditingProtocolProtocolxecutorKey);
}
- (void)setLf_protocolxecutor:(UIView<LFEditingProtocol> *)protocolxecutor
{
    objc_setAssociatedObject(self, LFEditingProtocolProtocolxecutorKey, protocolxecutor, OBJC_ASSOCIATION_ASSIGN);
}

- (LFDrawView *)lf_drawView
{
    return objc_getAssociatedObject(self, LFEditingProtocolDrawViewKey);
}
- (void)setLf_drawView:(LFDrawView *)drawView
{
    objc_setAssociatedObject(self, LFEditingProtocolDrawViewKey, drawView, OBJC_ASSOCIATION_ASSIGN);
}

- (LFStickerView *)lf_stickerView
{
    return objc_getAssociatedObject(self, LFEditingProtocolStickerViewKey);
}
- (void)setLf_stickerView:(LFStickerView *)stickerView
{
    objc_setAssociatedObject(self, LFEditingProtocolStickerViewKey, stickerView, OBJC_ASSOCIATION_ASSIGN);
}

- (LFDrawView *)lf_splashView
{
    return objc_getAssociatedObject(self, LFEditingProtocolSplashViewKey);
}
- (void)setLf_splashView:(LFDrawView *)splashView
{
    objc_setAssociatedObject(self, LFEditingProtocolSplashViewKey, splashView, OBJC_ASSOCIATION_ASSIGN);
}

- (id<LFFilterDataProtocol>)lf_displayView
{
    return objc_getAssociatedObject(self, LFEditingProtocolDisplayViewKey);
}
- (void)setLf_displayView:(id<LFFilterDataProtocol>)lf_displayView
{
    objc_setAssociatedObject(self, LFEditingProtocolDisplayViewKey, lf_displayView, OBJC_ASSOCIATION_ASSIGN);
}



#pragma mark - LFEditingProtocolPrivate property
- (BOOL)lf_editEnable
{
    NSNumber *num = objc_getAssociatedObject(self, LFEditingProtocolEditEnableKey);
    if (num != nil) {
        return [num boolValue];
    }
    return YES;
}
- (void)setLf_editEnable:(BOOL)editEnable
{
    objc_setAssociatedObject(self, LFEditingProtocolEditEnableKey, @(editEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lf_drawViewEnable
{
    return [objc_getAssociatedObject(self, LFEditingProtocolDrawViewEnableKey) boolValue];
}
- (void)setLf_drawViewEnable:(BOOL)drawViewEnable
{
    objc_setAssociatedObject(self, LFEditingProtocolDrawViewEnableKey, @(drawViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lf_stickerViewEnable
{
    return [objc_getAssociatedObject(self, LFEditingProtocolStickerViewEnableKey) boolValue];
}
- (void)setLf_stickerViewEnable:(BOOL)stickerViewEnable
{
    objc_setAssociatedObject(self, LFEditingProtocolStickerViewEnableKey, @(stickerViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lf_splashViewEnable
{
    return [objc_getAssociatedObject(self, LFEditingProtocolSplashViewEnableKey) boolValue];
}
- (void)setLf_splashViewEnable:(BOOL)splashViewEnable
{
    objc_setAssociatedObject(self, LFEditingProtocolSplashViewEnableKey, @(splashViewEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lf_drawLineWidth
{
    return [objc_getAssociatedObject(self, LFEditingProtocolDrawLineWidthKey) floatValue];
}
- (void)setLf_drawLineWidth:(CGFloat)lf_drawLineWidth
{
    objc_setAssociatedObject(self, LFEditingProtocolDrawLineWidthKey, @(lf_drawLineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lf_drawLineColor
{
    return objc_getAssociatedObject(self, LFEditingProtocolDrawLineColorKey);
}
- (void)setLf_drawLineColor:(UIColor *)lf_drawLineColor
{
    objc_setAssociatedObject(self, LFEditingProtocolDrawLineColorKey, lf_drawLineColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lf_splashLineWidth
{
    return [objc_getAssociatedObject(self, LFEditingProtocolSplashLineWidthKey) floatValue];
}
- (void)setLf_splashLineWidth:(CGFloat)lf_splashLineWidth
{
    objc_setAssociatedObject(self, LFEditingProtocolSplashLineWidthKey, @(lf_splashLineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - LFEditingProtocol

- (void)setEditDelegate:(id<LFPhotoEditDelegate>)editDelegate
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setEditDelegate:editDelegate];
        return;
    }
    objc_setAssociatedObject(self, LFEditingProtocolEditDelegateKey, editDelegate, OBJC_ASSOCIATION_ASSIGN);
    /** 设置代理回调 */
    __weak typeof(self) weakSelf = self;
    
    if (self.editDelegate) {
        /** 绘画 */
        self.lf_drawView.drawBegan = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(lf_photoEditDrawBegan)]) {
                [weakSelf.editDelegate lf_photoEditDrawBegan];
            }
        };
        
        self.lf_drawView.drawEnded = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(lf_photoEditDrawEnded)]) {
                [weakSelf.editDelegate lf_photoEditDrawEnded];
            }
        };
        
        /** 贴图 */
        self.lf_stickerView.tapEnded = ^(LFStickerItem *item, BOOL isActive) {
            if ([weakSelf.editDelegate respondsToSelector:@selector(lf_photoEditStickerDidSelectViewIsActive:)]) {
                [weakSelf.editDelegate lf_photoEditStickerDidSelectViewIsActive:isActive];
            }
        };
        
        /** 模糊 */
        self.lf_splashView.drawBegan = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(lf_photoEditSplashBegan)]) {
                [weakSelf.editDelegate lf_photoEditSplashBegan];
            }
        };
        
        self.lf_splashView.drawEnded = ^{
            if ([weakSelf.editDelegate respondsToSelector:@selector(lf_photoEditSplashEnded)]) {
                [weakSelf.editDelegate lf_photoEditSplashEnded];
            }
        };
    } else {
        self.lf_drawView.drawBegan = nil;
        self.lf_drawView.drawEnded = nil;
        self.lf_stickerView.tapEnded = nil;
        self.lf_splashView.drawBegan = nil;
        self.lf_splashView.drawEnded = nil;
    }
    
}

- (id<LFPhotoEditDelegate>)editDelegate
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor editDelegate];
    }
    return objc_getAssociatedObject(self, LFEditingProtocolEditDelegateKey);
}

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor photoEditEnable:enable];
        return;
    }
    if (self.lf_editEnable != enable) {
        self.lf_editEnable = enable;
        if (enable) {
            self.lf_drawView.userInteractionEnabled = self.lf_drawViewEnable;
            self.lf_splashView.userInteractionEnabled = self.lf_splashViewEnable;
            self.lf_stickerView.userInteractionEnabled = self.lf_stickerViewEnable;
        } else {
            self.lf_drawViewEnable = self.lf_drawView.userInteractionEnabled;
            self.lf_splashViewEnable = self.lf_splashView.userInteractionEnabled;
            self.lf_stickerViewEnable = self.lf_stickerView.userInteractionEnabled;
            self.lf_drawView.userInteractionEnabled = NO;
            self.lf_splashView.userInteractionEnabled = NO;
            self.lf_stickerView.userInteractionEnabled = NO;
        }
    }
}

#pragma mark - 滤镜功能
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor changeFilterType:cmType];
        return;
    }
    self.lf_displayView.type = cmType;
}
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor getFilterType];
    }
    return self.lf_displayView.type;
}
/** 获取滤镜图片 */
- (UIImage *)getFilterImage
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor getFilterImage];
    }
    if ([self.lf_displayView isKindOfClass:[LFFilterGifView class]]) {
        return [(LFFilterGifView *)self.lf_displayView renderedAnimatedUIImage];
    } else if ([self.lf_displayView isKindOfClass:[LFContextImageView class]]) {
        return [(LFContextImageView *)self.lf_displayView renderedUIImage];
    }
    return nil;
}

#pragma mark - 绘画功能
/** 启用绘画功能 */
- (void)setDrawEnable:(BOOL)drawEnable
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setDrawEnable:drawEnable];
        return;
    }
    self.lf_drawView.userInteractionEnabled = drawEnable;
}
- (BOOL)drawEnable
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor drawEnable];
    }
    return self.lf_drawView.userInteractionEnabled;
}
/** 正在绘画 */
- (BOOL)isDrawing
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor isDrawing];
    }
    return self.lf_drawView.isDrawing;
}

- (BOOL)drawCanUndo
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor drawCanUndo];
    }
    return self.lf_drawView.canUndo;
}
- (void)drawUndo
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor drawUndo];
        return;
    }
    [self.lf_drawView undo];
}
/** 设置绘画画笔 */
- (void)setDrawBrush:(LFBrush *)brush
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setDrawBrush:brush];
        return;
    }
    if (brush) {
        self.lf_drawView.brush = brush;
        [self setDrawLineWidth:self.lf_drawLineWidth];
        [self setDrawColor:self.lf_drawLineColor];
    }
}
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setDrawColor:color];
        return;
    }
    self.lf_drawLineColor = color;
    if ([self.lf_drawView.brush isKindOfClass:[LFBlurryBrush class]]) {
        // LFBlurryBrush 不因颜色而改变效果。
    } else if ([self.lf_drawView.brush isKindOfClass:[LFMosaicBrush class]]) {
        // LFMosaicBrush 不因颜色而改变效果。
    } else if ([self.lf_drawView.brush isKindOfClass:[LFEraserBrush class]]) {
        // LFEraserBrush 不因颜色而改变效果。
    } else if ([self.lf_drawView.brush isKindOfClass:[LFFluorescentBrush class]]) {
        ((LFFluorescentBrush *)self.lf_drawView.brush).lineColor = color;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFHighlightBrush class]]) {
        ((LFHighlightBrush *)self.lf_drawView.brush).outerLineColor = color;
        ((LFHighlightBrush *)self.lf_drawView.brush).lineColor = ([color isEqual:[UIColor whiteColor]]) ? [UIColor blackColor] : [UIColor whiteColor];
    } else if ([self.lf_drawView.brush isKindOfClass:[LFPaintBrush class]]) {
        ((LFPaintBrush *)self.lf_drawView.brush).lineColor = color;
    }
}

/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setDrawLineWidth:lineWidth];
        return;
    }
    self.lf_drawLineWidth = lineWidth;
    if ([self.lf_drawView.brush isKindOfClass:[LFSmearBrush class]]) {
        // 对涂抹画笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth*20;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFChalkBrush class]]) {
        // 对粉笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth*2.5;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFFluorescentBrush class]]) {
        // 对荧光笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth*4.5;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFBlurryBrush class]]) {
        // 对模糊笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth*5;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFMosaicBrush class]]) {
        // 对马赛克笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth*5;
    } else if ([self.lf_drawView.brush isKindOfClass:[LFEraserBrush class]]) {
        // 对橡皮擦笔的线粗相对调整
        self.lf_drawView.brush.lineWidth = lineWidth+4;
    } else {
        self.lf_drawView.brush.lineWidth = lineWidth;
        if ([self.lf_drawView.brush isKindOfClass:[LFHighlightBrush class]]) {
            // 对高亮画笔的外边线粗相对调整
            ((LFHighlightBrush *)self.lf_drawView.brush).outerLineWidth = lineWidth/1.6;
        }
    }
}

#pragma mark - 贴图功能
/** 贴图启用 */
- (BOOL)stickerEnable
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor stickerEnable];
    }
    return [self.lf_stickerView isEnable];
}
/** 取消激活贴图 */
- (void)stickerDeactivated
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor stickerDeactivated];
        return;
    }
    [LFStickerView LFStickerViewDeactivated];
}
/** 激活选中的贴图 */
- (void)activeSelectStickerView
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor activeSelectStickerView];
        return;
    }
    [self.lf_stickerView activeSelectStickerView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor removeSelectStickerView];
        return;
    }
    [self.lf_stickerView removeSelectStickerView];
}
/** 屏幕缩放率 */
- (void)setScreenScale:(CGFloat)scale
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setScreenScale:scale];
        return;
    }
    self.lf_stickerView.screenScale = scale;
}
- (CGFloat)screenScale
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor screenScale];
    }
    return self.lf_stickerView.screenScale;
}

/** 最小缩放率 默认0.2 */
- (void)setStickerMinScale:(CGFloat)stickerMinScale
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setStickerMinScale:stickerMinScale];
        return;
    }
    self.lf_stickerView.minScale = stickerMinScale;
}
- (CGFloat)stickerMinScale
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor stickerMinScale];
    }
    return self.lf_stickerView.minScale;
}
/** 最大缩放率 默认3.0 */
- (void)setStickerMaxScale:(CGFloat)stickerMaxScale
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setStickerMaxScale:stickerMaxScale];
        return;
    }
    self.lf_stickerView.maxScale = stickerMaxScale;
}
- (CGFloat)stickerMaxScale
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor stickerMaxScale];
    }
    return self.lf_stickerView.maxScale;
}
/** 创建贴图 */
- (void)createSticker:(LFStickerItem *)item
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor createSticker:item];
        return;
    }
    [self.lf_stickerView createStickerItem:item];
}
/** 获取选中贴图的内容 */
- (LFStickerItem *)getSelectSticker
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor getSelectSticker];
    }
    return [self.lf_stickerView getSelectStickerItem];
}
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(LFStickerItem *)item
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor changeSelectSticker:item];
        return;
    }
    [self.lf_stickerView changeSelectStickerItem:item];
}

#pragma mark - 模糊功能
/** 启用模糊功能 */
- (void)setSplashEnable:(BOOL)splashEnable
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setSplashEnable:splashEnable];
        return;
    }
    self.lf_splashView.userInteractionEnabled = splashEnable;
}
- (BOOL)splashEnable
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor splashEnable];
    }
    return self.lf_splashView.userInteractionEnabled;
}
/** 正在模糊 */
- (BOOL)isSplashing
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor isSplashing];
    }
    return self.lf_splashView.isDrawing;
}
/** 是否可撤销 */
- (BOOL)splashCanUndo
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor splashCanUndo];
    }
    return self.lf_splashView.canUndo;
}
/** 撤销模糊 */
- (void)splashUndo
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor splashUndo];
        return;
    }
    [self.lf_splashView undo];
}

/** 设置模糊画笔 */
- (LFSplashStateType)splashStateType
{
    if (self.lf_protocolxecutor) {
        return [self.lf_protocolxecutor splashStateType];
    }
    if ([self.lf_splashView.brush isKindOfClass:[LFMosaicBrush class]]) {
        return LFSplashStateType_Mosaic;
    } else if ([self.lf_splashView.brush isKindOfClass:[LFBlurryBrush class]]) {
        return LFSplashStateType_Blurry;
    } else if ([self.lf_splashView.brush isKindOfClass:[LFSmearBrush class]]) {
        return LFSplashStateType_Smear;
    }
    return LFSplashStateType_Mosaic;
}
- (void)setSplashStateType:(LFSplashStateType)splashStateType
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setSplashStateType:splashStateType];
        return;
    }
    LFBrush *brush = nil;
    switch (splashStateType) {
        case LFSplashStateType_Mosaic:
        {
            brush = [[LFMosaicBrush alloc] init];
        }
            break;
        case LFSplashStateType_Blurry:
        {
            brush = [[LFBlurryBrush alloc] init];
        }
            break;
        case LFSplashStateType_Smear:
        {
            brush = [[LFSmearBrush alloc] initWithImageName:@"brush/EditImageSmearBrush@2x.png"];
        }
            break;
    }
    if (brush) {
        brush.bundle = [NSBundle LF_mediaEditingBundle];
        [self.lf_splashView setBrush:brush];
        [self setSplashLineWidth:self.lf_splashLineWidth];
    }
}

/** 设置模糊线粗 */
- (void)setSplashLineWidth:(CGFloat)lineWidth
{
    if (self.lf_protocolxecutor) {
        [self.lf_protocolxecutor setSplashLineWidth:lineWidth];
        return;
    }
    self.lf_splashLineWidth = lineWidth;
    if ([self.lf_splashView.brush isKindOfClass:[LFSmearBrush class]]) {
        // 对涂抹画笔的线粗相对调整
        self.lf_splashView.brush.lineWidth = lineWidth*4;
    } else if ([self.lf_splashView.brush isKindOfClass:[LFBlurryBrush class]]) {
        // 对模糊笔的线粗相对调整
        self.lf_splashView.brush.lineWidth = lineWidth;
    } else if ([self.lf_splashView.brush isKindOfClass:[LFMosaicBrush class]]) {
        // 对马赛克笔的线粗相对调整
        self.lf_splashView.brush.lineWidth = lineWidth;
    }
}

@end
