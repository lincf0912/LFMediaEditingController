//
//  LFAssetExportSession.m
//
//  Created by TsanFeng Lam on 2020/4/8.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//


#import "LFAssetExportSession.h"

@implementation AVAsset (LFAssetDegress)

/// 获取视频角度
- (int)lf_degressFromVideo {
    int degress = 0;
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

@end

inline static CGSize lf_assetExportSessionPresetSize(LFAssetExportSessionPreset preset)
{
    CGSize size;
    switch (preset) {
        case LFAssetExportSessionPreset240P:
            size = CGSizeMake(240, 360);
            break;
        case LFAssetExportSessionPreset360P:
            size = CGSizeMake(360, 480);
            break;
        case LFAssetExportSessionPreset480P:
            size = CGSizeMake(480, 640);
            break;
        case LFAssetExportSessionPreset1080P:
            size = CGSizeMake(1080, 1920);
            break;
        case LFAssetExportSessionPreset2K:
            size = CGSizeMake(1440, 2560);
            break;
        case LFAssetExportSessionPreset4K:
            size = CGSizeMake(2160, 3840);
            break;
        case LFAssetExportSessionPreset720P:
        default:
            size = CGSizeMake(720, 1280);
            break;
    }
    
    return size;
}

inline static unsigned long lf_assetExportSessionPresetBitrate(LFAssetExportSessionPreset preset)
{
    // 根据这篇文章Video Encoding Settings for H.264 Excellence http://www.lighterra.com/papers/videoencodingh264/#maximumkeyframeinterval
    
    // Video Bitrate Calculator https://www.dr-lex.be/info-stuff/videocalc.html
    
    unsigned long bitrate = 0;
    switch (preset) {
        case LFAssetExportSessionPreset240P:
            bitrate = 450000;
            break;
        case LFAssetExportSessionPreset360P:
            bitrate = 770000;
            break;
        case LFAssetExportSessionPreset480P:
            bitrate = 1200000;
            break;
        case LFAssetExportSessionPreset1080P:
            bitrate = 7900000;
            break;
        case LFAssetExportSessionPreset2K:
            bitrate = 13000000;
            break;
        case LFAssetExportSessionPreset4K:
            bitrate = 31000000;
            break;
        case LFAssetExportSessionPreset720P:
        default:
            bitrate = 3500000;
            break;
    }
    return bitrate;
}

inline static NSDictionary *lf_assetExportVideoConfig(CGSize size, LFAssetExportSessionPreset preset)
{
    float ratio = 1;
    CGSize presetSize = lf_assetExportSessionPresetSize(preset);
    CGSize videoSize = size;
    if (videoSize.width > videoSize.height) {
        ratio = videoSize.width / presetSize.height;
    } else {
        ratio = videoSize.width / presetSize.width;
    }
    
    if (ratio > 1) {
        videoSize = CGSizeMake(videoSize.width / ratio, videoSize.height / ratio);
    }
    
    unsigned long bitrate = lf_assetExportSessionPresetBitrate(preset);
    
    return @{
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey:[NSNumber numberWithInteger:videoSize.width],
        AVVideoHeightKey:[NSNumber numberWithInteger:videoSize.height],
        AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
        AVVideoCompressionPropertiesKey: @
        {
            AVVideoAverageBitRateKey: [NSNumber numberWithUnsignedLong:bitrate],
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoAllowFrameReorderingKey:@NO,
            AVVideoExpectedSourceFrameRateKey:@30
        },
    };
}

//inline static NSDictionary *lf_assetExportVideoOutputFilterConfig(void)
//{
//    return @{
//        (id)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
//        (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]
//    };
//}

inline static NSDictionary *lf_assetExportVideoOutputConfig(void)
{
    return @{
        (id)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
        (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]
    };
}

inline static NSDictionary *lf_assetExportAudioOutputConfig(void)
{
    return @{
        AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM]
    };
}

inline static NSDictionary *lf_assetExportAudioConfig(void)
{
    return @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000
    };
}

@interface LFAssetExportSession ()

@property (nonatomic, assign, readwrite) float progress;

@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetReaderOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderOutput *audioOutput;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, assign) CGSize inputBufferSize;
@property (nonatomic, assign) int videoOrientation;
@property (nonatomic, assign) LFAssetExportSessionPreset preset;
@property (nonatomic, strong) dispatch_queue_t inputQueue;
@property (nonatomic, strong) void (^completionHandler)(void);

@end

@implementation LFAssetExportSession
{
    NSError *_error;
    NSTimeInterval duration;
    CMTime lastSamplePresentationTime;
}

+ (instancetype)exportSessionWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset
{
    return [[[self class] alloc] initWithAsset:asset preset:preset];
}

- (instancetype)initWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset
{
    if ((self = [super init]))
    {
        _preset = preset;
        _asset = asset;
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
        _videoOrientation = [asset lf_degressFromVideo];
    }

    return self;
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(void))handler
{
    NSParameterAssert(handler != nil);
    [self cancelExport];
    
    _cancelled = NO;
    
    if (!self.outputURL)
    {
        _error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{
                NSLocalizedDescriptionKey: @"Output URL not set"
        }];
        handler();
        return;
    }
    
    NSError *readerError;
    AVAssetReader *reader = [AVAssetReader.alloc initWithAsset:self.asset error:&readerError];
    if (readerError)
    {
        _error = readerError;
        handler();
        return;
    }
    
    NSError *writerError;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:self.outputURL fileType:self.outputFileType error:&writerError];
    if (writerError)
    {
        _error = writerError;
        handler();
        return;
    }
    self.reader = reader;
    self.writer = writer;
                      
    
    self.completionHandler = handler;
    
    if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration))
    {
        duration = CMTimeGetSeconds(self.timeRange.duration);
    }
    else
    {
        duration = CMTimeGetSeconds(self.asset.duration);
    }
    
    self.reader.timeRange = self.timeRange;
    self.writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    self.writer.metadata = self.metadata;
    
    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    
    //
    // Video output
    //
    if (videoTracks.count > 0) {
        
        AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
        
        
        AVVideoComposition *videoComposition = self.videoComposition;
        if (videoComposition == nil)
        {
            videoComposition = [self buildDefaultVideoComposition];
        }
        
        if (videoComposition == nil) {
            _inputBufferSize = videoTrack.naturalSize;
        } else {
            _inputBufferSize = videoComposition.renderSize;
        }
        
        NSDictionary *settings = self.videoOutputSettings;
        
        if (settings == nil) {
            settings = lf_assetExportVideoOutputConfig();
        }
        
        AVAssetReaderOutput *videoOutput = nil;
        if (videoComposition == nil) {
            videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:settings];
        } else {
            AVAssetReaderVideoCompositionOutput *videoCompositionOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:settings];
            videoCompositionOutput.videoComposition = videoComposition;
            videoOutput = videoCompositionOutput;
        }
        
        videoOutput.alwaysCopiesSampleData = NO;
        
        if ([self.reader canAddOutput:videoOutput])
        {
            [self.reader addOutput:videoOutput];
            self.videoOutput = videoOutput;
        }
        
        //
        // Video input
        //
        
        NSDictionary *videoSettings = self.videoSettings;
        
        if (videoSettings == nil) {
            videoSettings = lf_assetExportVideoConfig(_inputBufferSize, self.preset);
        }
        
        AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        videoInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:videoInput])
        {
            [self.writer addInput:videoInput];
            self.videoInput = videoInput;
        }
        
        if (self.videoInput) {
            NSDictionary *pixelBufferAttributes = @
            {
                (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                (id)kCVPixelBufferWidthKey: @(self.inputBufferSize.width),
                (id)kCVPixelBufferHeightKey: @(self.inputBufferSize.height),
                (id)kCVPixelFormatOpenGLESCompatibility: @YES
            };
            self.videoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:pixelBufferAttributes];
        }
    }
    
    //
    //Audio output
    //
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        NSDictionary *settings = lf_assetExportAudioOutputConfig();
        
        AVAudioMix *audioMix = self.audioMix;
        AVAssetReaderOutput *audioOutput = nil;
        if (audioMix == nil) {
            audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTracks.firstObject outputSettings:settings];
        } else {
            AVAssetReaderAudioMixOutput *audioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:settings];
            audioMixOutput.audioMix = audioMix;
            audioOutput = audioMixOutput;
        }
        audioOutput.alwaysCopiesSampleData = NO;
        if ([self.reader canAddOutput:audioOutput])
        {
            [self.reader addOutput:audioOutput];
            self.audioOutput = audioOutput;
        }
    } else {
        // Just in case this gets reused
        self.audioOutput = nil;
    }
    
    //
    // Audio input
    //
    if (self.audioOutput) {
        
        NSDictionary *settings = self.audioSettings;
        if (settings == nil) {
            settings = lf_assetExportAudioConfig();
        }
        
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
        self.audioInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:self.audioInput])
        {
            [self.writer addInput:self.audioInput];
        }
    }
    
    [self.writer startWriting];
    [self.reader startReading];
    [self.writer startSessionAtSourceTime:self.timeRange.start];
    
    __block BOOL videoCompleted = NO;
    __block BOOL audioCompleted = NO;
    __weak typeof(self) wself = self;
    self.inputQueue = dispatch_queue_create("LFAssetExportSessionInputQueue", DISPATCH_QUEUE_SERIAL);
    if (videoTracks.count > 0) {
        [self.videoInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^
         {
            if (![wself encodeReadySamplesFromOutput:wself.videoOutput toInput:wself.videoInput])
            {
                @synchronized(wself)
                {
                    videoCompleted = YES;
                    if (audioCompleted)
                    {
                        if (!wself.cancelled) {
                            [wself _setProgress:1.0];
                        }
                        [wself finish];
                    }
                }
            }
        }];
    }
    else {
        videoCompleted = YES;
    }
    
    if (!self.audioOutput) {
        audioCompleted = YES;
    } else {
        [self.audioInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^
         {
            if (![wself encodeReadySamplesFromOutput:wself.audioOutput toInput:wself.audioInput])
            {
                @synchronized(wself)
                {
                    audioCompleted = YES;
                    if (videoCompleted)
                    {
                        if (!wself.cancelled) {
                            [wself _setProgress:1.0];
                        }
                        [wself finish];
                    }
                }
            }
        }];
    }
}

- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output toInput:(AVAssetWriterInput *)input
{
    while (input.isReadyForMoreMediaData)
    {
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer && !self.cancelled)
        {
            
            BOOL handled = NO;
            BOOL error = NO;

            if (self.reader.status != AVAssetReaderStatusReading || self.writer.status != AVAssetWriterStatusWriting)
            {
                handled = YES;
                error = YES;
            }
            
            if (!handled && self.videoOutput == output)
            {
                // update the video progress
                lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                lastSamplePresentationTime = CMTimeSubtract(lastSamplePresentationTime, self.timeRange.start);
                float progress = duration == 0 ? 1 : CMTimeGetSeconds(lastSamplePresentationTime) / duration;
                [self _setProgress:progress];

                if ([self.delegate respondsToSelector:@selector(assetExportSession:renderFrame:withPresentationTime:toBuffer:)])
                {
                    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
                    CVPixelBufferRef renderBuffer = NULL;
                    CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, self.videoPixelBufferAdaptor.pixelBufferPool, &renderBuffer);
                    if (status != kCVReturnSuccess){
                        NSLog(@"Failed to create pixel buffer");
                    }
                    [self.delegate assetExportSession:self renderFrame:pixelBuffer withPresentationTime:lastSamplePresentationTime toBuffer:renderBuffer];
                    if (![self.videoPixelBufferAdaptor appendPixelBuffer:renderBuffer withPresentationTime:lastSamplePresentationTime])
                    {
                        error = YES;
                    }
                    if (renderBuffer) {
                        CVPixelBufferRelease(renderBuffer);                        
                    }
                    handled = YES;
                }
            }
            if (!handled && ![input appendSampleBuffer:sampleBuffer])
            {
                error = YES;
            }
            CFRelease(sampleBuffer);

            if (error)
            {
                return NO;
            }
        }
        else
        {
            [input markAsFinished];
            return NO;
        }
    }

    return YES;
}

- (AVMutableVideoComposition *)buildDefaultVideoComposition
{
    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:self.asset];
    
    if (videoComposition) {
        
        AVAssetTrack *videoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        // get the frame rate from videoSettings, if not set then try to get it from the video track,
        // if not set (mainly when asset is AVComposition) then use the default frame rate of 30
        float trackFrameRate = 0;
        if (self.videoSettings)
        {
            NSDictionary *videoCompressionProperties = [self.videoSettings objectForKey:AVVideoCompressionPropertiesKey];
            if (videoCompressionProperties)
            {
                NSNumber *frameRate = [videoCompressionProperties objectForKey:AVVideoAverageNonDroppableFrameRateKey];
                if (frameRate)
                {
                    trackFrameRate = frameRate.floatValue;
                }
            }
        }
        else
        {
            trackFrameRate = [videoTrack nominalFrameRate];
        }
        
        if (trackFrameRate == 0)
        {
            trackFrameRate = 30;
        }
        
        videoComposition.frameDuration = CMTimeMake(1, trackFrameRate);
    }

    return videoComposition;
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = nil;
    // 视频转向
    int degrees = self.videoOrientation;
    if (degrees != 0) {
        
        videoComposition = [AVMutableVideoComposition videoComposition];
        
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }else {
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

- (void)finish
{
    // Synchronized block to ensure we never cancel the writer before calling finishWritingWithCompletionHandler
    if (self.reader.status == AVAssetReaderStatusCancelled || self.writer.status == AVAssetWriterStatusCancelled)
    {
        [self complete];
        return;
    }
    
    if (self.reader.status == AVAssetReaderStatusFailed || self.writer.status == AVAssetWriterStatusFailed)
    {
        [self.reader cancelReading];
        [self.writer cancelWriting];
        [self complete];
    }
    else
    {
        [self.writer finishWritingWithCompletionHandler:^
         {
            [self complete];
        }];
    }
}

- (void)complete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.writer.status == AVAssetWriterStatusFailed || self.writer.status == AVAssetWriterStatusCancelled)
        {
            [NSFileManager.defaultManager removeItemAtURL:self.outputURL error:nil];
        }
        
        if (self.completionHandler)
        {
            self.completionHandler();
            self.completionHandler = nil;
        }
        [self reset];
    });
}

- (NSError *)error
{
    if (_error)
    {
        return _error;
    }
    else
    {
        return self.writer.error ? : self.reader.error;
    }
}

- (AVAssetExportSessionStatus)status
{
    switch (self.writer.status)
    {
        default:
        case AVAssetWriterStatusUnknown:
            return AVAssetExportSessionStatusUnknown;
        case AVAssetWriterStatusWriting:
            return AVAssetExportSessionStatusExporting;
        case AVAssetWriterStatusFailed:
            return AVAssetExportSessionStatusFailed;
        case AVAssetWriterStatusCompleted:
            return AVAssetExportSessionStatusCompleted;
        case AVAssetWriterStatusCancelled:
            return AVAssetExportSessionStatusCancelled;
    }
}

- (void)cancelExport
{
    _cancelled = YES;
    if (self.inputQueue)
    {
        dispatch_sync(self.inputQueue, ^
        {
            [self.writer cancelWriting];
            [self.reader cancelReading];
        });
    }
}

- (void)_setProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:@"progress"];
        
        self->_progress = progress;
        
        [self didChangeValueForKey:@"progress"];
        
        id<LFAssetExportSessionDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(assetExportSessionDidProgress:)]) {
            [delegate assetExportSessionDidProgress:self];
        }
    });
}

- (void)reset
{
    _error = nil;
    _progress = 0;
    _inputBufferSize = CGSizeZero;
    self.reader = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.writer = nil;
    self.videoInput = nil;
    self.videoPixelBufferAdaptor = nil;
    self.audioInput = nil;
    self.inputQueue = nil;
    self.completionHandler = nil;
}

@end
