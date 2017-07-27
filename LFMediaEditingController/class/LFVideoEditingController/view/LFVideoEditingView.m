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

#import "UIView+LFMEFrame.h"

/** 默认剪辑尺寸 */
#define kDefaultClipRect CGRectInset(self.frame , 20, 70)

@interface LFVideoEditingView () <LFVideoClippingViewDelegate, LFVideoTrimmerViewDelegate>

/** 视频剪辑 */
@property (nonatomic, weak) LFVideoClippingView *clippingView;

/** 视频时间轴 */
@property (nonatomic, weak) LFVideoTrimmerView *trimmerView;

/** 剪裁尺寸 */
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) LFVideoExportSession *exportSession;


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

- (void)customInit
{
    _minClippingDuration = 1.f;
    
    LFVideoClippingView *clippingView = [[LFVideoClippingView alloc] initWithFrame:self.bounds];
    clippingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    clippingView.clipDelegate = self;
    __weak typeof(self) weakSelf = self;
    clippingView.moveCenter = ^BOOL(CGRect rect) {
        /** 判断缩放后贴图是否超出边界线 */
        CGRect newRect = [weakSelf.clippingView convertRect:rect toView:weakSelf];
        CGRect screenRect = weakSelf.frame;
        return !CGRectIntersectsRect(screenRect, newRect);
    };
    [self addSubview:clippingView];
    _clippingView = clippingView;
    
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, kDefaultClipRect);
    CGFloat r_margin = 15.f, l_margin = 50;
    LFVideoTrimmerView *trimmerView = [[LFVideoTrimmerView alloc] initWithFrame:CGRectMake(l_margin, CGRectGetHeight(rect)+r_margin, self.bounds.size.width-l_margin*2, CGRectGetHeight(self.bounds)-CGRectGetHeight(rect)-44-r_margin*2)];
    trimmerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    trimmerView.hidden = YES;
    trimmerView.delegate = self;
    [self addSubview:trimmerView];
    _trimmerView = trimmerView;
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
    
    [self.clippingView save];
    [self.clippingView replayVideo];
    CGFloat x = self.clippingView.startTime/self.clippingView.totalDuration*self.trimmerView.width;
    CGFloat width = self.clippingView.endTime/self.clippingView.totalDuration*self.trimmerView.width-x;
    [self.trimmerView setGridRect:CGRectMake(x, 0, width, self.trimmerView.height) animated:NO];
    _isClipping = isClipping;
    if (isClipping) {
        /** 动画切换 */
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, kDefaultClipRect);
                rect.origin.y = 0;
                self.clippingRect = rect;
            } completion:^(BOOL finished) {
                self.trimmerView.hidden = NO;
                if (self.trimmerView.asset == nil) {
                    self.trimmerView.asset = self.asset;
                }
            }];
        } else {
            CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, kDefaultClipRect);
            rect.origin.y = 0;
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
                CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.frame);
                self.clippingRect = cropRect;
                self.trimmerView.hidden = YES;
            }];
        } else {
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.size, self.frame);
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
    self.asset = asset;
    [self.clippingView setVideoAsset:asset placeholderImage:image];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (self.isClipping && view == self) {
        return self.trimmerView;
    }
    
    return view;
}

/** 剪辑视频 */
- (void)exportAsynchronouslyWithTrimVideo:(void (^)(NSURL *trimURL))complete
{
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.LFMediaEditing.video"];
    BOOL exist = [fm fileExistsAtPath:path];
    if (!exist) {
        if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
        }
    }
    
    NSString *name = nil;
    if ([self.asset isKindOfClass:[AVURLAsset class]]) {
        name = ((AVURLAsset *)self.asset).URL.lastPathComponent;
    } else {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        name = [result stringByAppendingPathExtension:@"mp4"];
    }
    
    NSString *trimPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Edit.mp4", [name stringByDeletingPathExtension]]];
    NSURL *trimURL = [NSURL fileURLWithPath:trimPath];
    /** 删除原来剪辑的视频 */
    exist = [fm fileExistsAtPath:trimPath];
    if (exist) {
        if (![fm removeItemAtPath:trimPath error:&error]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    
    /** 剪辑 */
    CMTime start = CMTimeMakeWithSeconds(self.clippingView.startTime, self.asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.clippingView.endTime - self.clippingView.startTime, self.asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    
    self.exportSession = [[LFVideoExportSession alloc] initWithAsset:self.asset];
    self.exportSession.outputURL = trimURL;
    self.exportSession.timeRange = range;
    self.exportSession.overlayView = self.clippingView.overlayView;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (complete) complete((error ? nil : trimURL));
    }];
}

#pragma mark - LFVideoClippingViewDelegate
/** 视频准备完毕，可以获取相关属性与操作 */
- (void)lf_videLClippingViewReadyToPlay:(LFVideoClippingView *)clippingView
{
    self.trimmerView.controlMinWidth = self.trimmerView.width * (self.minClippingDuration / clippingView.totalDuration);
}
/** 进度回调 */
- (void)lf_videoClippingView:(LFVideoClippingView *)clippingView duration:(double)duration
{
    self.trimmerView.progress = duration/clippingView.totalDuration;
}

/** 进度长度 */
- (CGFloat)lf_videoClippingViewProgressWidth:(LFVideoClippingView *)clippingView
{
    return self.trimmerView.width;
}

#pragma mark - LFVideoTrimmerViewDelegate
- (void)lf_videoTrimmerViewDidBeginResizing:(LFVideoTrimmerView *)trimmerView gridRect:(CGRect)gridRect
{
    [self.clippingView pauseVideo];
    [self lf_videoTrimmerViewDidResizing:trimmerView gridRect:gridRect];
    [self.clippingView beginScrubbing];
    [trimmerView setHiddenProgress:YES];
    trimmerView.progress = 0;
}
- (void)lf_videoTrimmerViewDidResizing:(LFVideoTrimmerView *)trimmerView gridRect:(CGRect)gridRect
{
    double startTime = gridRect.origin.x/trimmerView.width*self.clippingView.totalDuration;
    double endTime = (gridRect.origin.x+gridRect.size.width)/trimmerView.width*self.clippingView.totalDuration;
    
    [self.clippingView seekToTime:((self.clippingView.startTime != startTime) ? startTime : endTime)];
    
    self.clippingView.startTime = startTime;
    self.clippingView.endTime = endTime;
    
}
- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView gridRect:(CGRect)gridRect
{
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

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    return self.clippingView.photoEditData;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    self.clippingView.photoEditData = photoEditData;
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
