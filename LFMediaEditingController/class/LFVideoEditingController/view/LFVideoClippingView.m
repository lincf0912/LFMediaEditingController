//
//  LFVideoClippingView.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFVideoClippingView.h"
#import "LFVideoPlayer.h"
#import "LFVideoPlayerLayerView.h"
#import "UIView+LFMECommon.h"
#import "UIView+LFMEFrame.h"
#import "LFMediaEditingHeader.h"

/** 编辑功能 */
#import "LFDrawView.h"
#import "LFSplashView.h"
#import "LFStickerView.h"

/** 滤镜框架 */
#import "LFDataFilterVideoView.h"

NSString *const kLFVideoCLippingViewData = @"LFVideoCLippingViewData";

NSString *const kLFVideoCLippingViewData_startTime = @"LFVideoCLippingViewData_startTime";
NSString *const kLFVideoCLippingViewData_endTime = @"LFVideoCLippingViewData_endTime";
NSString *const kLFVideoCLippingViewData_rate = @"LFVideoCLippingViewData_rate";

NSString *const kLFVideoCLippingViewData_draw = @"LFVideoCLippingViewData_draw";
NSString *const kLFVideoCLippingViewData_sticker = @"LFVideoCLippingViewData_sticker";
NSString *const kLFVideoCLippingViewData_splash = @"LFVideoCLippingViewData_splash";
NSString *const kLFVideoCLippingViewData_filter = @"LFVideoCLippingViewData_filter";

@interface LFVideoClippingView () <LFVideoPlayerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) LFDataFilterVideoView *playerView;
@property (nonatomic, strong) LFVideoPlayer *videoPlayer;

/** 原始坐标 */
@property (nonatomic, assign) CGRect originalRect;

/** 缩放视图 */
@property (nonatomic, weak) UIView *zoomView;

/** 绘画 */
@property (nonatomic, weak) LFDrawView *drawView;
/** 贴图 */
@property (nonatomic, weak) LFStickerView *stickerView;
/** 模糊 */
@property (nonatomic, weak) LFSplashView *splashView;

/** 代理 */
@property (nonatomic ,weak) id<LFPhotoEditDelegate> editDelegate_self;
@property (nonatomic, assign) BOOL muteOriginal;
@property (nonatomic, strong) NSArray <NSURL *>*audioUrls;
@property (nonatomic, strong) AVAsset *asset;

/** 记录编辑层是否可控 */
@property (nonatomic, assign) BOOL editEnable;
@property (nonatomic, assign) BOOL drawViewEnable;
@property (nonatomic, assign) BOOL stickerViewEnable;
@property (nonatomic, assign) BOOL splashViewEnable;


#pragma mark 编辑数据
/** 开始播放时间 */
@property (nonatomic, assign) double old_startTime;
/** 结束播放时间 */
@property (nonatomic, assign) double old_endTime;

@end

@implementation LFVideoClippingView

@synthesize rate = _rate;

/*
 1、播放功能（无限循环）
 2、暂停／继续功能
 3、视频编辑功能
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _originalRect = frame;
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.editEnable = YES;
    
    /** 缩放视图 */
    UIView *zoomView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:zoomView];
    _zoomView = zoomView;
    
    
    /** 播放视图 */
    LFDataFilterVideoView *playerView = [[LFDataFilterVideoView alloc] initWithFrame:self.bounds];
    playerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.zoomView addSubview:playerView];
    _playerView = playerView;
    
    /** 涂抹 - 最底层 */
//    LFSplashView_new *splashView = [[LFSplashView_new alloc] initWithFrame:self.bounds];
//    __weak typeof(self) weakSelf = self;
//    splashView.splashColor = ^UIColor *(CGPoint point) {
//        return [weakSelf.playerLayerView LFME_colorOfPoint:point];
//    };
//    /** 默认不能涂抹 */
//    splashView.userInteractionEnabled = NO;
//    [self addSubview:splashView];
//    self.splashView = splashView;
    
    /** 绘画 */
    LFDrawView *drawView = [[LFDrawView alloc] initWithFrame:self.bounds];
    /**
     默认画笔
     */
    drawView.brush = [LFPaintBrush new];
    /** 默认不能触发绘画 */
    drawView.userInteractionEnabled = NO;
    [self.zoomView addSubview:drawView];
    self.drawView = drawView;
    
    /** 贴图 */
    LFStickerView *stickerView = [[LFStickerView alloc] initWithFrame:self.bounds];
    /** 禁止后，贴图将不能拖到，设计上，贴图是永远可以拖动的 */
    //    stickerView.userInteractionEnabled = NO;
    [self.zoomView addSubview:stickerView];
    self.stickerView = stickerView;
}

- (void)dealloc
{
    [self.videoPlayer pause];
    self.videoPlayer.delegate = nil;
    self.videoPlayer = nil;
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    _asset = asset;
    [self.playerView setImageByUIImage:image];
    if (self.videoPlayer == nil) {
        self.videoPlayer = [LFVideoPlayer new];
        self.videoPlayer.delegate = self;
    }
    [self.videoPlayer setAsset:asset];
    [self.videoPlayer setAudioUrls:self.audioUrls];
    if (_rate > 0 && !(_rate + FLT_EPSILON > 1.0 && _rate - FLT_EPSILON < 1.0)) {
        self.videoPlayer.rate = _rate;
    }
    
    /** 重置编辑UI位置 */
    CGSize videoSize = self.videoPlayer.size;
    if (CGSizeEqualToSize(CGSizeZero, videoSize) || isnan(videoSize.width) || isnan(videoSize.height)) {
        videoSize = self.zoomView.size;
    }
    CGRect editRect = AVMakeRectWithAspectRatioInsideRect(videoSize, self.superview.bounds);
    self.frame = editRect;
    _zoomView.size = editRect.size;
    _playerView.frame = _drawView.frame = _splashView.frame = _stickerView.frame = _zoomView.bounds;
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

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    
    self.frame = cropRect;
//    _playerLayerView.center = _drawView.center = _splashView.center = _stickerView.center = self.center;
    
    /** 重置最小缩放比例 */
    CGRect rotateNormalRect = CGRectApplyAffineTransform(self.originalRect, self.transform);
    CGFloat minimumZoomScale = MAX(CGRectGetWidth(self.frame) / CGRectGetWidth(rotateNormalRect), CGRectGetHeight(self.frame) / CGRectGetHeight(rotateNormalRect));
    self.minimumZoomScale = minimumZoomScale;
    self.maximumZoomScale = minimumZoomScale;
    
    [self setZoomScale:minimumZoomScale];
}

/** 保存 */
- (void)save
{
    self.old_startTime = self.startTime;
    self.old_endTime = self.endTime;
}
/** 取消 */
- (void)cancel
{
    self.startTime = self.old_startTime;
    self.endTime = self.old_endTime;
}

/** 播放 */
- (void)playVideo
{
    [self.videoPlayer play];
    [self seekToTime:self.startTime];
}

/** 暂停 */
- (void)pauseVideo
{
    [self.videoPlayer pause];
}

/** 静音原音 */
- (void)muteOriginalVideo:(BOOL)mute
{
    _muteOriginal = mute;
    self.videoPlayer.muteOriginalSound = mute;
}

- (float)rate
{
    return self.videoPlayer.rate ?: 1.0;
}

- (void)setRate:(float)rate
{
    _rate = rate;
    self.videoPlayer.rate = rate;
}

/** 是否播放 */
- (BOOL)isPlaying
{
    return [self.videoPlayer isPlaying];
}

/** 重新播放 */
- (void)replayVideo
{
    [self.videoPlayer resetDisplay];
    if (![self.videoPlayer isPlaying]) {
        [self.videoPlayer play];
    }
    [self seekToTime:self.startTime];
}

/** 重置视频 */
- (void)resetVideoDisplay
{
    [self.videoPlayer pause];
    [self.videoPlayer resetDisplay];
    [self seekToTime:self.startTime];
}

/** 增加音效 */
- (void)setAudioMix:(NSArray <NSURL *>*)audioMix
{
    _audioUrls = audioMix;
    [self.videoPlayer setAudioUrls:self.audioUrls];
}

/** 移动到某帧 */
- (void)seekToTime:(CGFloat)time
{
    [self.videoPlayer seekToTime:time];
}

- (void)beginScrubbing
{
    _isScrubbing = YES;
    [self.videoPlayer beginScrubbing];
}

- (void)endScrubbing
{
    _isScrubbing = NO;
    [self.videoPlayer endScrubbing];
}

/** 是否存在水印 */
- (BOOL)hasWatermark
{
    return self.drawView.canUndo || self.splashView.canUndo || self.stickerView.subviews.count;
}

- (UIView *)overlayView
{
    if (self.hasWatermark) {
        
        NSDictionary *data = self.photoEditData;
        
        UIView *copyZoomView = [[UIView alloc] initWithFrame:self.zoomView.bounds];
        copyZoomView.hidden = NO;
        copyZoomView.backgroundColor = [UIColor clearColor];
        copyZoomView.userInteractionEnabled = NO;
        
        NSDictionary *drawData = data[kLFVideoCLippingViewData_draw];
        if (drawData) {
            /** 绘画 */
            LFDrawView *drawView = [[LFDrawView alloc] initWithFrame:copyZoomView.bounds];
            [copyZoomView addSubview:drawView];
            [drawView setData:drawData];
        }
        
        NSDictionary *stickerData = data[kLFVideoCLippingViewData_sticker];
        if (stickerData) {
            /** 贴图 */
            LFStickerView *stickerView = [[LFStickerView alloc] initWithFrame:copyZoomView.bounds];
            [copyZoomView addSubview:stickerView];
            [stickerView setData:stickerData];
        }
        
        return copyZoomView;
    }
    return nil;
}

- (LFFilter *)filter
{
    return self.playerView.filter;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomView;
}

#pragma mark - LFVideoPlayerDelegate
/** 画面回调 */
- (void)LFVideoPlayerLayerDisplay:(LFVideoPlayer *)player avplayer:(AVPlayer *)avplayer
{
    if (self.startTime > 0) {
        [player seekToTime:self.startTime];
    }
    [self.playerView setPlayer:avplayer];
//    [self.playerLayerView setImage:nil];
}
/** 可以播放 */
- (void)LFVideoPlayerReadyToPlay:(LFVideoPlayer *)player duration:(double)duration
{
    if (_endTime == 0) { /** 读取配置优于视频初始化的情况 */
        _endTime = duration;
    }
    _totalDuration = duration;
    self.videoPlayer.muteOriginalSound = self.muteOriginal;
    [self playVideo];
    if ([self.clipDelegate respondsToSelector:@selector(lf_videLClippingViewReadyToPlay:)]) {
        [self.clipDelegate lf_videLClippingViewReadyToPlay:self];
    }
}

/** 播放结束 */
- (void)LFVideoPlayerPlayDidReachEnd:(LFVideoPlayer *)player
{
    [self playVideo];
}
/** 错误回调 */
- (void)LFVideoPlayerFailedToPrepare:(LFVideoPlayer *)player error:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[[UIAlertView alloc] initWithTitle:@"LFVideoPlayer_Error"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:[NSBundle LFME_localizedStringForKey:@"_LFME_alertViewCancelTitle"]
                      otherButtonTitles:nil]
     show];
#pragma clang diagnostic pop
}

/** 进度回调2-手动实现 */
- (void)LFVideoPlayerSyncScrub:(LFVideoPlayer *)player duration:(double)duration
{
    if (self.isScrubbing) return;
    if (duration > self.endTime) {
        [self replayVideo];
    } else {
        if ([self.clipDelegate respondsToSelector:@selector(lf_videoClippingView:duration:)]) {
            [self.clipDelegate lf_videoClippingView:self duration:duration];
        }
    }
}

/** 进度长度 */
- (CGFloat)LFVideoPlayerSyncScrubProgressWidth:(LFVideoPlayer *)player
{
    if ([self.clipDelegate respondsToSelector:@selector(lf_videoClippingViewProgressWidth:)]) {
        return [self.clipDelegate lf_videoClippingViewProgressWidth:self];
    }
    return [UIScreen mainScreen].bounds.size.width;
}


#pragma mark - LFEditingProtocol

- (void)setEditDelegate:(id<LFPhotoEditDelegate>)editDelegate
{
    _editDelegate_self = editDelegate;
    /** 设置代理回调 */
    __weak typeof(self) weakSelf = self;
    
    if (_editDelegate_self) {
        /** 绘画 */
        _drawView.drawBegan = ^{
            if ([weakSelf.editDelegate_self respondsToSelector:@selector(lf_photoEditDrawBegan)]) {
                [weakSelf.editDelegate_self lf_photoEditDrawBegan];
            }
        };
        
        _drawView.drawEnded = ^{
            if ([weakSelf.editDelegate_self respondsToSelector:@selector(lf_photoEditDrawEnded)]) {
                [weakSelf.editDelegate_self lf_photoEditDrawEnded];
            }
        };
        
        /** 贴图 */
        _stickerView.tapEnded = ^(LFStickerItem *item, BOOL isActive) {
            if ([weakSelf.editDelegate_self respondsToSelector:@selector(lf_photoEditStickerDidSelectViewIsActive:)]) {
                [weakSelf.editDelegate_self lf_photoEditStickerDidSelectViewIsActive:isActive];
            }
        };
        
        /** 模糊 */
        _splashView.splashBegan = ^{
            if ([weakSelf.editDelegate_self respondsToSelector:@selector(lf_photoEditSplashBegan)]) {
                [weakSelf.editDelegate_self lf_photoEditSplashBegan];
            }
        };
        
        _splashView.splashEnded = ^{
            if ([weakSelf.editDelegate_self respondsToSelector:@selector(lf_photoEditSplashEnded)]) {
                [weakSelf.editDelegate_self lf_photoEditSplashEnded];
            }
        };
    } else {
        _drawView.drawBegan = nil;
        _drawView.drawEnded = nil;
        _stickerView.tapEnded = nil;
        _splashView.splashBegan = nil;
        _splashView.splashEnded = nil;
    }
    
}

- (id<LFPhotoEditDelegate>)editDelegate
{
    return _editDelegate_self;
}

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable
{
    if (_editEnable != enable) {
        _editEnable = enable;
        if (enable) {
            _drawView.userInteractionEnabled = _drawViewEnable;
            _splashView.userInteractionEnabled = _splashViewEnable;
            _stickerView.userInteractionEnabled = _stickerViewEnable;
        } else {
            _drawViewEnable = _drawView.userInteractionEnabled;
            _splashViewEnable = _splashView.userInteractionEnabled;
            _stickerViewEnable = _stickerView.userInteractionEnabled;
            _drawView.userInteractionEnabled = NO;
            _splashView.userInteractionEnabled = NO;
            _stickerView.userInteractionEnabled = NO;
        }
    }
}

/** 显示视图 */
- (UIView *)displayView
{
    return self.playerView;
}

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSDictionary *drawData = _drawView.data;
    NSDictionary *stickerData = _stickerView.data;
    NSDictionary *splashData = _splashView.data;
    NSDictionary *filterData = _playerView.data;
    
    NSMutableDictionary *data = [@{} mutableCopy];
    if (drawData) [data setObject:drawData forKey:kLFVideoCLippingViewData_draw];
    if (stickerData) [data setObject:stickerData forKey:kLFVideoCLippingViewData_sticker];
    if (splashData) [data setObject:splashData forKey:kLFVideoCLippingViewData_splash];
    if (filterData) [data setObject:filterData forKey:kLFVideoCLippingViewData_filter];
    
    if (self.startTime > 0 || self.endTime < self.totalDuration || (_rate > 0 && !(_rate + FLT_EPSILON > 1.0 && _rate - FLT_EPSILON < 1.0))) {
        NSDictionary *myData = @{kLFVideoCLippingViewData_startTime:@(self.startTime)
                                 , kLFVideoCLippingViewData_endTime:@(self.endTime)
                                 , kLFVideoCLippingViewData_rate:@(self.rate)};
        [data setObject:myData forKey:kLFVideoCLippingViewData];
    }
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    NSDictionary *myData = photoEditData[kLFVideoCLippingViewData];
    if (myData) {
        self.startTime = self.old_startTime = [myData[kLFVideoCLippingViewData_startTime] doubleValue];
        self.endTime = self.old_endTime = [myData[kLFVideoCLippingViewData_endTime] doubleValue];
        self.rate = [myData[kLFVideoCLippingViewData_rate] floatValue];
    }
    _drawView.data = photoEditData[kLFVideoCLippingViewData_draw];
    _stickerView.data = photoEditData[kLFVideoCLippingViewData_sticker];
    _splashView.data = photoEditData[kLFVideoCLippingViewData_splash];
    _playerView.data = photoEditData[kLFVideoCLippingViewData_filter];
}

#pragma mark - 滤镜功能
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType
{
    self.playerView.type = cmType;
}
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType
{
    return self.playerView.type;
}
/** 获取滤镜图片 */
- (UIImage *)getFilterImage
{
    return [self.playerView renderedUIImage];
}

#pragma mark - 绘画功能
/** 启用绘画功能 */
- (void)setDrawEnable:(BOOL)drawEnable
{
    _drawView.userInteractionEnabled = drawEnable;
}
- (BOOL)drawEnable
{
    return _drawView.userInteractionEnabled;
}

- (BOOL)isDrawing
{
    return _drawView.isDrawing;
}

- (BOOL)drawCanUndo
{
    return _drawView.canUndo;
}
- (void)drawUndo
{
    [_drawView undo];
}
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color
{
    if ([_drawView.brush isKindOfClass:[LFPaintBrush class]]) {
        ((LFPaintBrush *)_drawView.brush).lineColor = color;
    }
}

/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth
{
    _drawView.brush.lineWidth = lineWidth;
}

#pragma mark - 贴图功能
/** 贴图启用 */
- (BOOL)stickerEnable
{
    return _stickerView.isEnable;
}
/** 取消激活贴图 */
- (void)stickerDeactivated
{
    [LFStickerView LFStickerViewDeactivated];
}
/** 激活选中的贴图 */
- (void)activeSelectStickerView
{
    [_stickerView activeSelectStickerView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    [_stickerView removeSelectStickerView];
}
/** 屏幕缩放率 */
- (void)setScreenScale:(CGFloat)scale
{
    _stickerView.screenScale = scale;
}
/** 最小缩放率 默认0.2 */
- (void)setStickerMinScale:(CGFloat)stickerMinScale
{
    _stickerView.minScale = stickerMinScale;
}
- (CGFloat)stickerMinScale
{
    return _stickerView.minScale;
}
/** 最大缩放率 默认3.0 */
- (void)setStickerMaxScale:(CGFloat)stickerMaxScale
{
    _stickerView.maxScale = stickerMaxScale;
}
- (CGFloat)stickerMaxScale
{
    return _stickerView.maxScale;
}

/** 创建贴图 */
- (void)createSticker:(LFStickerItem *)item
{
    [_stickerView createStickerItem:item];
}
/** 获取选中贴图的内容 */
- (LFStickerItem *)getSelectSticker
{
    return [_stickerView getSelectStickerItem];
}
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(LFStickerItem *)item
{
    [_stickerView changeSelectStickerItem:item];
}

#pragma mark - 模糊功能
/** 启用模糊功能 */
- (void)setSplashEnable:(BOOL)splashEnable
{
    _splashView.userInteractionEnabled = splashEnable;
}
- (BOOL)splashEnable
{
    return _splashView.userInteractionEnabled;
}
/** 是否可撤销 */
- (BOOL)splashCanUndo
{
    return _splashView.canUndo;
}
/** 撤销模糊 */
- (void)splashUndo
{
    [_splashView undo];
}
- (BOOL)isSplashing
{
    return _splashView.isDrawing;
}
- (void)setSplashState:(BOOL)splashState
{
    if (splashState) {
        _splashView.state = LFSplashStateType_Paintbrush;
    } else {
        _splashView.state = LFSplashStateType_Mosaic;
    }
}

- (BOOL)splashState
{
    return _splashView.state == LFSplashStateType_Paintbrush;
}

/** 设置马赛克大小 */
- (void)setSplashWidth:(CGFloat)squareWidth
{
    _splashView.squareWidth = squareWidth;
}
/** 设置画笔大小 */
- (void)setPaintWidth:(CGFloat)paintWidth
{
    _splashView.paintSize = CGSizeMake(paintWidth, paintWidth);
}

@end
