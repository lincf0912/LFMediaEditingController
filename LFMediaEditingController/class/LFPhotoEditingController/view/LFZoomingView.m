//
//  LFZoomingView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/16.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFZoomingView.h"
#import "UIView+LFMEFrame.h"
#import "UIView+LFMECommon.h"
#import "UIImage+LFMECommon.h"

#import <AVFoundation/AVFoundation.h>

/** 编辑功能 */
#import "LFDataFilterImageView.h"
#import "LFDrawView.h"
#import "LFStickerView.h"

NSString *const kLFZoomingViewData_draw = @"LFZoomingViewData_draw";
NSString *const kLFZoomingViewData_sticker = @"LFZoomingViewData_sticker";
NSString *const kLFZoomingViewData_splash = @"LFZoomingViewData_splash";
NSString *const kLFZoomingViewData_filter = @"LFZoomingViewData_filter";

@interface LFZoomingView ()

@property (nonatomic, weak) LFDataFilterImageView *imageView;

/** 绘画 */
@property (nonatomic, weak) LFDrawView *drawView;
/** 贴图 */
@property (nonatomic, weak) LFStickerView *stickerView;
/** 模糊（马赛克、高斯模糊、涂抹） */
@property (nonatomic, weak) LFDrawView *splashView;

@end

@implementation LFZoomingView

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
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    LFDataFilterImageView *imageView = [[LFDataFilterImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    /** 模糊，实际上它是一个绘画层。设计上它与绘画层的操作不一样。 */
    LFDrawView *splashView = [[LFDrawView alloc] initWithFrame:self.bounds];
    /** 默认画笔 */
    splashView.brush = [LFMosaicBrush new];
    /** 默认不能涂抹 */
    splashView.userInteractionEnabled = NO;
    [self addSubview:splashView];
    self.splashView = splashView;
    
    /** 绘画 */
    LFDrawView *drawView = [[LFDrawView alloc] initWithFrame:self.bounds];
    /** 默认画笔 */
    drawView.brush = [LFPaintBrush new];
    /** 默认不能触发绘画 */
    drawView.userInteractionEnabled = NO;
    [self addSubview:drawView];
    self.drawView = drawView;
    
    /** 贴图 */
    LFStickerView *stickerView = [[LFStickerView alloc] initWithFrame:self.bounds];
    /** 禁止后，贴图将不能拖到，设计上，贴图是永远可以拖动的 */
//    stickerView.userInteractionEnabled = NO;
    [self addSubview:stickerView];
    self.stickerView = stickerView;
    
    // 实现LFEditingProtocol协议
    {
        self.lf_imageView = self.imageView;
        self.lf_drawView = self.drawView;
        self.lf_stickerView = self.stickerView;
        self.lf_splashView = self.splashView;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 子控件更新 */
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = self.bounds;
    }];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image durations:nil];
}

- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations
{
    _image = image;
    CGSize imageSize = image.size;
    
    if (image) {
        /** 判断是否大图、长图之类的图片，暂时规定超出当前手机屏幕的n倍就是大图了 */
        CGFloat scale = 12.5f;
        BOOL isLongImage = MAX(imageSize.height/imageSize.width, imageSize.width/imageSize.height) > scale;
        if (image.images.count == 0 && (isLongImage || (imageSize.width > [UIScreen mainScreen].bounds.size.width * scale || imageSize.height > [UIScreen mainScreen].bounds.size.height * scale))) { // 长图UIView -> CATiledLayer
            self.imageView.contextType = LFContextTypeLargeImage;
        } else { //正常图UIView
            self.imageView.contextType = LFContextTypeDefault;
        }
    }
    [self.imageView setImageByUIImage:image durations:durations];
}

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate
{
    UIImage *image = nil;
    NSMutableArray *array = nil;
    
    for (UIView *subView in self.subviews) {
        
        if (subView == self.imageView) {
            continue;
        } else if ([subView isKindOfClass:[LFDrawView class]]) {
            if (((LFDrawView *)subView).count  == 0) {
                continue;
            }
        } else if ([subView isKindOfClass:[LFStickerView class]]) {
            if (((LFStickerView *)subView).count  == 0) {
                continue;
            }
        }
        if (array == nil) {
            array = [NSMutableArray arrayWithCapacity:3];
        }
        [array addObject:[subView LFME_captureImageAtFrame:rect]];
        
    }
    
    if (array.count) {
        image = [UIImage LFME_mergeimages:array];
        if (rotate) {
            image = [image LFME_imageRotatedByRadians:rotate];
        }
    }
    
    return image;
}

- (void)setMoveCenter:(BOOL (^)(CGRect))moveCenter
{
    _moveCenter = moveCenter;
    if (moveCenter) {
        _stickerView.moveCenter = moveCenter;
    } else {
        _stickerView.moveCenter = nil;
    }
}

#pragma mark - LFEditingProtocol

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSDictionary *drawData = _drawView.data;
    NSDictionary *stickerData = _stickerView.data;
    NSDictionary *splashData = _splashView.data;
    NSDictionary *filterData = _imageView.data;
    
    NSMutableDictionary *data = [@{} mutableCopy];
    if (drawData) [data setObject:drawData forKey:kLFZoomingViewData_draw];
    if (stickerData) [data setObject:stickerData forKey:kLFZoomingViewData_sticker];
    if (splashData) [data setObject:splashData forKey:kLFZoomingViewData_splash];
    if (filterData) [data setObject:filterData forKey:kLFZoomingViewData_filter];
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    _drawView.data = photoEditData[kLFZoomingViewData_draw];
    _stickerView.data = photoEditData[kLFZoomingViewData_sticker];
    _splashView.data = photoEditData[kLFZoomingViewData_splash];
    _imageView.data = photoEditData[kLFZoomingViewData_filter];
}

@end
