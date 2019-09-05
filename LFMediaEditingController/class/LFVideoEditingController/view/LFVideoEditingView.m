//
//  LFVideoEditingView.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFVideoEditingView.h"
#import "LFVideoClippingView.h"
#import "LFVideoTrimmerView.h"
#import <AVFoundation/AVFoundation.h>
#import "LFVideoExportSession.h"
#import "LFAudioTrackBar.h"

#import "UIView+LFMEFrame.h"

/** 默认剪辑尺寸 */
#define kClipZoom_margin 20.f

#define kVideoTrimmer_tb_margin 10.f
#define kVideoTrimmer_lr_margin 50.f
#define kVideoTrimmer_h 80.f

NSString *const kLFVideoEditingViewData = @"LFVideoEditingViewData";
NSString *const kLFVideoEditingViewData_clipping = @"LFVideoEditingViewData_clipping";

NSString *const kLFVideoEditingViewData_audioUrlList = @"LFVideoEditingViewData_audioUrlList";

NSString *const kLFVideoEditingViewData_audioUrl = @"LFVideoEditingViewData_audioUrl";
NSString *const kLFVideoEditingViewData_audioTitle = @"LFVideoEditingViewData_audioTitle";
NSString *const kLFVideoEditingViewData_audioOriginal = @"LFVideoEditingViewData_audioOriginal";
NSString *const kLFVideoEditingViewData_audioEnable = @"LFVideoEditingViewData_audioEnable";

@interface LFVideoEditingView () <LFVideoClippingViewDelegate, LFVideoTrimmerViewDelegate>

/** 视频剪辑 */
@property (nonatomic, weak) LFVideoClippingView *clippingView;

/** 视频时间轴 */
@property (nonatomic, weak) LFVideoTrimmerView *trimmerView;

/** 剪裁尺寸 */
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) LFVideoExportSession *exportSession;

/* 底部栏高度 默认44 */
@property (nonatomic, assign) CGFloat editToolbarDefaultHeight;

@end

@implementation LFVideoEditingView

/*
 1、播放功能（无限循环）
 2、暂停／继续功能
 3、视频水印功能
 4、视频编辑功能
    4.1、涂鸦
    4.2、贴图
    4.3、文字
    4.4、马赛克
    4.5、视频剪辑功能
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)dealloc
{
    [self.exportSession cancelExport];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat toolbarHeight = self.editToolbarDefaultHeight;
    
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.safeAreaInsets.bottom;
    }
    
    self.trimmerView.frame = CGRectMake(kVideoTrimmer_lr_margin, CGRectGetHeight(self.bounds)-kVideoTrimmer_h-toolbarHeight-kVideoTrimmer_tb_margin, self.bounds.size.width-kVideoTrimmer_lr_margin*2, kVideoTrimmer_h);
}

- (void)customInit
{
    self.backgroundColor = [UIColor blackColor];
    _minClippingDuration = 1.f;
    _maxClippingDuration = 0.f;
    _editToolbarDefaultHeight = 44.f;
    
    LFVideoClippingView *clippingView = [[LFVideoClippingView alloc] initWithFrame:self.bounds];
    clippingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    clippingView.clipDelegate = self;
    __weak typeof(self) weakSelf = self;
    clippingView.moveCenter = ^BOOL(CGRect rect) {
        /** 判断缩放后贴图是否超出边界线 */
        CGRect newRect = [weakSelf.clippingView convertRect:rect toView:weakSelf];
        CGRect screenRect = weakSelf.frame;
        screenRect = CGRectInset(screenRect, 44, 44);
        return !CGRectIntersectsRect(screenRect, newRect);
    };
    [self addSubview:clippingView];
    _clippingView = clippingView;
    
    LFVideoTrimmerView *trimmerView = [[LFVideoTrimmerView alloc] initWithFrame:CGRectMake(kVideoTrimmer_lr_margin, CGRectGetHeight(self.bounds)-kVideoTrimmer_h-self.editToolbarDefaultHeight-kVideoTrimmer_tb_margin, self.bounds.size.width-kVideoTrimmer_lr_margin*2, kVideoTrimmer_h)];
    trimmerView.hidden = YES;
    trimmerView.delegate = self;
    [self addSubview:trimmerView];
    _trimmerView = trimmerView;
}

- (UIEdgeInsets)refer_clippingInsets
{
    CGFloat top = kClipZoom_margin;
    CGFloat left = kClipZoom_margin;
    CGFloat bottom = self.editToolbarDefaultHeight + kVideoTrimmer_h + kVideoTrimmer_tb_margin*2;
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

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    self.clippingView.cropRect = clippingRect;
}

- (void)setIsClipping:(BOOL)isClipping
{
    [self setIsClipping:isClipping animated:NO];
}
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated
{
    /** 获取总时长才进行记录，否则等待总时长获取后再操作 */
    if (self.clippingView.totalDuration) {
        [self.clippingView save];
        [self.clippingView replayVideo];
        CGFloat x = self.clippingView.startTime/self.clippingView.totalDuration*self.trimmerView.width;
        CGFloat width = self.clippingView.endTime/self.clippingView.totalDuration*self.trimmerView.width-x;
        [self.trimmerView setGridRange:NSMakeRange(x, width) animated:NO];
    }
    _isClipping = isClipping;
    if (isClipping) {
        /** 动画切换 */
        if (animated) {
            self.trimmerView.hidden = NO;
            self.trimmerView.alpha = 0.f;
            CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, [self refer_clippingRect]);
            [UIView animateWithDuration:0.25f animations:^{
                self.clippingRect = rect;
                self.trimmerView.alpha = 1.f;
            } completion:^(BOOL finished) {
                if (self.trimmerView.asset == nil) {
                    self.trimmerView.asset = self.asset;
                }
            }];
        } else {
            CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, [self refer_clippingRect]);
            self.clippingRect = rect;
            self.trimmerView.hidden = NO;
            if (self.trimmerView.asset == nil) {
                self.trimmerView.asset = self.asset;
            }
        }
    } else {
        /** 重置最大缩放 */
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.bounds);
                self.clippingRect = cropRect;
                self.trimmerView.alpha = 0.f;
            } completion:^(BOOL finished) {
                self.trimmerView.alpha = 1.f;
                self.trimmerView.hidden = YES;
            }];
        } else {
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.bounds);
            self.clippingRect = cropRect;
            self.trimmerView.hidden = YES;
        }
    }
}

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated
{
    [self.clippingView cancel];
    [self setIsClipping:NO animated:animated];
}

- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image
{
    if (self.audioUrls == nil) {
        /** 创建默认音轨 */
        LFAudioItem *item = [LFAudioItem defaultAudioItem];
        self.audioUrls = @[item];
    }
    self.asset = asset;
    [self.clippingView setVideoAsset:asset placeholderImage:image];
    
    [self setNeedsDisplay];
}

- (void)setAudioUrls:(NSArray<LFAudioItem *> *)audioUrls
{
    _audioUrls = audioUrls;
    NSMutableArray <NSURL *>*audioMixUrls = [@[] mutableCopy];
    BOOL isMuteOriginal = NO;
    for (LFAudioItem *item in audioUrls) {
        if (item.isOriginal) {
            isMuteOriginal = !item.isEnable;
        } else if (item.url && item.isEnable) {
            [audioMixUrls addObject:item.url];
        }
    }
    [self.clippingView setAudioMix:audioMixUrls];
    [self.clippingView muteOriginalVideo:isMuteOriginal];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (self.isClipping && view == self) {
        return self.trimmerView;
    }
    
    return view;
}

- (float)rate
{
    return self.clippingView.rate;
}

- (void)setRate:(float)rate
{
    self.clippingView.rate = rate;
}

/** 播放 */
- (void)playVideo
{
    [self.clippingView playVideo];
}
/** 暂停 */
- (void)pauseVideo
{
    [self.clippingView pauseVideo];
}
/** 重置视频 */
- (void)resetVideoDisplay
{
    [self.clippingView resetVideoDisplay];
}

/** 导出视频 */
- (void)exportAsynchronouslyWithTrimVideo:(void (^)(NSURL *trimURL, NSError *error))complete progress:(void (^)(float progress))progress
{
    [self pauseVideo];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.LFMediaEditing.video"];
    BOOL exist = [fm fileExistsAtPath:path];
    
    /** 删除原来剪辑的视频 */
    if (exist) {
        if (![fm removeItemAtPath:path error:&error]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
    }
    
    NSString *name = nil;
    
    if ([self.asset isKindOfClass:[AVURLAsset class]]) {
        name = ((AVURLAsset *)self.asset).URL.lastPathComponent;
    } if ([self.asset isKindOfClass:[AVComposition class]]) {
        AVCompositionTrack *avcompositionTrack = (AVCompositionTrack *)[self.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVCompositionTrackSegment *segment = avcompositionTrack.segments.firstObject;
        name = segment.sourceURL.lastPathComponent;
    }
    if (name.length == 0) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        name = result;
    }
    
    
    NSString *trimPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Edit%d.mp4", [name stringByDeletingPathExtension], (int)[[NSDate date] timeIntervalSince1970]]];
    NSURL *trimURL = [NSURL fileURLWithPath:trimPath];
    
    /** 剪辑 */
    CMTime start = CMTimeMakeWithSeconds(self.clippingView.startTime, self.asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.clippingView.endTime - self.clippingView.startTime, self.asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    self.exportSession = [[LFVideoExportSession alloc] initWithAsset:self.asset];
    // 输出路径
    self.exportSession.outputURL = trimURL;
    // 视频剪辑
    self.exportSession.timeRange = range;
    // 水印
    self.exportSession.overlayView = self.clippingView.overlayView;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (@available(iOS 9.0, *)) {
        // 滤镜
        self.exportSession.filter = self.clippingView.filter;
    }
#pragma clang diagnostic pop
    // 速率
    self.exportSession.rate = self.rate;
    // 音频
    NSMutableArray *audioUrls = [@[] mutableCopy];
    for (LFAudioItem *item in self.audioUrls) {
        if (item.isEnable && item.url) {
            [audioUrls addObject:item.url];
        }
        if (item.isOriginal) {
            self.exportSession.isOrignalSound = item.isEnable;
        }
    }
    self.exportSession.audioUrls = audioUrls;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (complete) complete(trimURL, error);
    } progress:progress];
}

#pragma mark - LFVideoClippingViewDelegate
/** 视频准备完毕，可以获取相关属性与操作 */
- (void)lf_videLClippingViewReadyToPlay:(LFVideoClippingView *)clippingView
{
    self.trimmerView.controlMinWidth = self.trimmerView.width * (self.minClippingDuration / clippingView.totalDuration);
    if (self.maxClippingDuration > 0) {
        self.trimmerView.controlMaxWidth = self.trimmerView.width * (self.maxClippingDuration / clippingView.totalDuration);
        /** 处理剪辑时间超出范围的情况 */
        double differ = self.clippingView.endTime - self.clippingView.startTime - self.maxClippingDuration;
        if (differ > 0) {
            self.clippingView.endTime = MAX(self.clippingView.endTime - differ, self.clippingView.startTime);
            
        }
    }
    if (self.isClipping) {
        [self.clippingView save];
        CGFloat x = self.clippingView.startTime/self.clippingView.totalDuration*self.trimmerView.width;
        CGFloat width = self.clippingView.endTime/self.clippingView.totalDuration*self.trimmerView.width-x;
        [self.trimmerView setGridRange:NSMakeRange(x, width) animated:NO];
    }
}
/** 进度回调 */
- (void)lf_videoClippingView:(LFVideoClippingView *)clippingView duration:(double)duration
{
    if (duration == 0) {
        self.trimmerView.progress = clippingView.startTime/clippingView.totalDuration;
    } else {
        self.trimmerView.progress = duration/clippingView.totalDuration;
    }
}

/** 进度长度 */
- (CGFloat)lf_videoClippingViewProgressWidth:(LFVideoClippingView *)clippingView
{
    return self.trimmerView.width;
}

#pragma mark - LFVideoTrimmerViewDelegate
- (void)lf_videoTrimmerViewDidBeginResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    [self.clippingView pauseVideo];
    [self lf_videoTrimmerViewDidResizing:trimmerView gridRange:gridRange];
    [self.clippingView beginScrubbing];
    [trimmerView setHiddenProgress:YES];
    trimmerView.progress = self.clippingView.startTime/self.clippingView.totalDuration;
}
- (void)lf_videoTrimmerViewDidResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
//    double startTime = MIN(lfme_videoDuration(gridRange.location/trimmerView.width*self.clippingView.totalDuration), self.clippingView.totalDuration);
//    double endTime = MIN(lfme_videoDuration((gridRange.location+gridRange.length)/trimmerView.width*self.clippingView.totalDuration), self.clippingView.totalDuration);

    double startTime = gridRange.location/trimmerView.width*self.clippingView.totalDuration;
    double endTime = (gridRange.location+gridRange.length)/trimmerView.width*self.clippingView.totalDuration;
    
    [self.clippingView seekToTime:((self.clippingView.startTime != startTime) ? startTime : endTime)];
    
    self.clippingView.startTime = startTime;
    self.clippingView.endTime = endTime;
    
}
- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    trimmerView.progress = self.clippingView.startTime/self.clippingView.totalDuration;
    [self.clippingView endScrubbing];
    [self.clippingView playVideo];
    [trimmerView setHiddenProgress:NO];
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
    NSDictionary *subData = self.clippingView.photoEditData;
    NSMutableDictionary *data = [@{} mutableCopy];
    if (subData) [data setObject:subData forKey:kLFVideoEditingViewData_clipping];
    
    if (self.audioUrls.count) {
        NSMutableArray *audioDatas = [@[] mutableCopy];
        BOOL hasOriginal = NO;
        for (LFAudioItem *item in self.audioUrls) {
            
            NSMutableDictionary *myData = [@{} mutableCopy];
            if (item.title) {
                [myData setObject:item.title forKey:kLFVideoEditingViewData_audioTitle];
            }
            if (item.url) {
                [myData setObject:item.url forKey:kLFVideoEditingViewData_audioUrl];
            }
            [myData setObject:@(item.isOriginal) forKey:kLFVideoEditingViewData_audioOriginal];
            [myData setObject:@(item.isEnable) forKey:kLFVideoEditingViewData_audioEnable];
            
            /** 忽略没有启用的音频 */
//            if (item.isEnable || item.isOriginal) {
//                [audioDatas addObject:myData];
//            }
            if (item.isOriginal && item.isEnable) {
                hasOriginal = YES;
            }
            [audioDatas addObject:myData];
        }
        if (!(hasOriginal && audioDatas.count == 1)) { /** 只有1个并且是原音，忽略数据 */
            [data setObject:@{kLFVideoEditingViewData_audioUrlList:audioDatas} forKey:kLFVideoEditingViewData];
        }
    }
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    NSDictionary *myData = [photoEditData objectForKey:kLFVideoEditingViewData];
    if (myData) {
        NSArray *audioUrlList = myData[kLFVideoEditingViewData_audioUrlList];
        NSMutableArray <LFAudioItem *>*audioUrls = [@[] mutableCopy];
        for (NSDictionary *audioDict in audioUrlList) {
            LFAudioItem *item = [LFAudioItem new];
            item.title = audioDict[kLFVideoEditingViewData_audioTitle];
            item.url = audioDict[kLFVideoEditingViewData_audioUrl];
            item.isEnable = [audioDict[kLFVideoEditingViewData_audioEnable] boolValue];
            [audioUrls addObject:item];
        }
        if (audioUrls.count) {
            self.audioUrls = [audioUrls copy];
        }
    }
    self.clippingView.photoEditData = photoEditData[kLFVideoEditingViewData_clipping];
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
/** 设置绘画画笔 */
- (void)setDrawBrush:(LFBrush *)brush
{
    [self.clippingView setDrawBrush:brush];
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
- (BOOL)isSplashing
{
    return self.clippingView.isSplashing;
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
