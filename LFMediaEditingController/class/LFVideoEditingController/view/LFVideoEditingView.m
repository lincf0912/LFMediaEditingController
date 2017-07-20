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

#import "UIView+LFMEFrame.h"
#import "UIView+LFMECommon.h"
#import "UIImage+LFMECommon.h"

/** 默认剪辑尺寸 */
#define kDefaultClipRect CGRectInset(self.frame , 20, 70)

@interface LFVideoEditingView () <LFVideoClippingViewDelegate, LFVideoTrimmerViewDelegate>

/** 视频剪辑 */
@property (nonatomic, weak) LFVideoClippingView *clippingView;

/** 视频时间轴 */
@property (nonatomic, weak) LFVideoTrimmerView *trimmerView;

/** 剪裁尺寸 */
@property (nonatomic, assign) CGRect clippingRect;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;

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
    self.exportSession = nil;
    self.composition = nil;
    self.videoComposition = nil;
}

- (void)customInit
{
    _minClippingDuration = 5.f;
    
    LFVideoClippingView *clippingView = [[LFVideoClippingView alloc] initWithFrame:self.bounds];
    clippingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    clippingView.delegate = self;
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
    self.clippingView.frame = clippingRect;
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

- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image
{
    self.url = url;
    self.asset = [AVAsset assetWithURL:self.url];
    [self.clippingView setVideoURL:url placeholderImage:image];
}

- (CALayer *)buildAnimatedTitleLayerForSize:(CGSize)size
{
    UIView *overlayView = self.clippingView.overlayView;
    UIImage *image = [overlayView LFME_captureImage];
    image = [image LFME_scaleToSize:size];
    
    // 1 - Set up the layer
    CALayer *layer = [CALayer layer];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:layer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    return overlayLayer;
}

/** 剪辑视频 */
- (void)exportAsynchronouslyWithTrimVideo:(void (^)(NSURL *trimURL))complete
{
    [self.exportSession cancelExport];
    self.exportSession = nil;
    self.composition = nil;
    self.videoComposition = nil;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.LFMediaEditing.video"];
    BOOL exist = [fm fileExistsAtPath:path];
    if (!exist) {
        if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
        }
    }
    NSString *trimPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tmp.%@", [self.url.lastPathComponent stringByDeletingPathExtension], self.url.pathExtension]];
    NSURL *trimURL = [NSURL fileURLWithPath:trimPath];
    /** 删除原来剪辑的视频 */
    exist = [fm fileExistsAtPath:trimPath];
    if (exist) {
        if (![fm removeItemAtPath:trimPath error:&error]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    /** 剪辑 */
    CMTime start = CMTimeMakeWithSeconds(self.clippingView.startTime, self.asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.clippingView.endTime - self.clippingView.startTime, self.asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    CMTime insertionPoint = kCMTimeZero;
    
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    // Check if a composition already exists, else create a composition using the input asset
    
    self.composition = [[AVMutableComposition alloc] init];
    
    // Insert the video and audio tracks from AVAsset
    if (assetVideoTrack != nil) {
        // 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
        AVMutableCompositionTrack *compositionVideoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.asset.duration) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
    }
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.asset.duration) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
    }
    
    /** 水印 */
    if(self.clippingView.hasWatermark) {
        
        AVAssetTrack *videoTrack = [self.composition tracksWithMediaType:AVMediaTypeVideo][0];
        // Step 2
        // Create a water mark layer of the same size as that of a video frame from the asset
        if (videoTrack) {
            // AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
            
            // AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            [passThroughLayer setTransform:assetVideoTrack.preferredTransform atTime:kCMTimeZero];
            [passThroughLayer setOpacity:0.0 atTime:self.asset.duration];
            
            passThroughInstruction.layerInstructions = [NSArray arrayWithObjects:passThroughLayer, nil];
            
            // build a pass through video composition
            // 管理所有视频轨道，可以决定最终视频的尺寸
            self.videoComposition = [AVMutableVideoComposition videoComposition];
            self.videoComposition.renderSize = assetVideoTrack.naturalSize;
            self.videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
            self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
            
            CALayer *animatedLayer = [self buildAnimatedTitleLayerForSize:self.videoComposition.renderSize];
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
            videoLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:animatedLayer];
            
            self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        }
    }
    
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:AVAssetExportPresetMediumQuality];
    // Implementation continues.
    self.exportSession.videoComposition = self.videoComposition;
    self.exportSession.timeRange = range;
//    self.exportSession.shouldOptimizeForNetworkUse = YES;
    
    NSString *outputFileType = AVFileTypeMPEG4;
    self.exportSession.outputURL = trimURL;
    NSString *suffix = trimURL.pathExtension;
    if ([suffix isEqualToString:@"mp4"]) {
        outputFileType = AVFileTypeMPEG4;
    } else if ([suffix isEqualToString:@"m4a"]) {
        outputFileType = AVFileTypeAppleM4A;
    } else if ([suffix isEqualToString:@"m4v"]) {
        outputFileType = AVFileTypeAppleM4V;
    } else if ([suffix isEqualToString:@"mov"]) {
        outputFileType = AVFileTypeQuickTimeMovie;
    }
    self.exportSession.outputFileType = outputFileType;
    
    if (self.asset.duration.timescale == 0 || self.exportSession == nil) {
        /** 这个情况AVAssetExportSession会卡死 */
        if (complete) complete(nil);
        return;
    }
    
    __weak typeof(self.exportSession) weakExportSession = self.exportSession;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([weakExportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[weakExportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export completed");
                    break;
                default:
                    break;
            }
            if ([weakExportSession status] == AVAssetExportSessionStatusCompleted && [fm fileExistsAtPath:trimURL.path]) {
                if (complete) complete(trimURL);
            } else {
                if (complete) complete(nil);
            }
        });
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
- (void)lf_videoTrimmerViewDidBeginResizing:(LFVideoTrimmerView *)trimmerView
{
    [self.clippingView pauseVideo];
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
- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView
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
