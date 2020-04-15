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
        case LFAssetExportSessionPreset540P:
            size = CGSizeMake(540, 960);
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

inline static LFAssetExportSessionPreset lf_assetExportSessionPresetFromSize(CGSize size)
{
    if (size.width > size.height) {
        CGFloat width = size.width;
        size.width = size.height;
        size.height = width;
    }
    
    if (size.width <= 240 && size.height <= 360) {
        return LFAssetExportSessionPreset240P;
    }
    if (size.width <= 360 && size.height <= 480) {
        return LFAssetExportSessionPreset360P;
    }
    if (size.width <= 480 && size.height <= 640) {
        return LFAssetExportSessionPreset480P;
    }
    if (size.width <= 540 && size.height <= 960) {
        return LFAssetExportSessionPreset540P;
    }
    if (size.width <= 720 && size.height <= 1280) {
        return LFAssetExportSessionPreset720P;
    }
    if (size.width <= 1080 && size.height <= 1920) {
        return LFAssetExportSessionPreset1080P;
    }
    if (size.width <= 1440 && size.height <= 2560) {
        return LFAssetExportSessionPreset2K;
    }
    if (size.width <= 2160 && size.height <= 3840) {
        return LFAssetExportSessionPreset4K;
    }
    return LFAssetExportSessionPreset240P;
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
        case LFAssetExportSessionPreset540P:
            bitrate = 2074000;
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
    
    LFAssetExportSessionPreset realPreset = lf_assetExportSessionPresetFromSize(videoSize);
    unsigned long bitrate = lf_assetExportSessionPresetBitrate(realPreset);
    
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
        AVFormatIDKey: [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM],
        AVSampleRateKey: @44100,
        AVNumberOfChannelsKey: @2,
        AVLinearPCMBitDepthKey: @16,
        AVLinearPCMIsBigEndianKey: @NO,
        AVLinearPCMIsFloatKey: @NO,
        AVLinearPCMIsNonInterleaved: @NO
    };
}

inline static NSDictionary *lf_assetExportAudioConfig(void)
{
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    return @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVChannelLayoutKey: [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000
    };
}

@interface LFAssetExportSession ()
{
    dispatch_queue_t _audioQueue;
    dispatch_queue_t _videoQueue;
    dispatch_group_t _dispatchGroup;
}
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
@property (nonatomic, assign) BOOL needsLeaveAudio;
@property (nonatomic, assign) BOOL needsLeaveVideo;

@property (nonatomic, strong) void (^completionHandler)(void);

@end

@implementation LFAssetExportSession
{
    NSError *_error;
    Float64 _totalDuration;
    CMTime lastSamplePresentationTime;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _audioQueue = dispatch_queue_create("me.corsin.SCAssetExportSession.AudioQueue", nil);
        _videoQueue = dispatch_queue_create("me.corsin.SCAssetExportSession.VideoQueue", nil);
        _dispatchGroup = dispatch_group_create();
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
        _shouldOptimizeForNetworkUse = NO;
    }

    return self;
}

+ (instancetype)exportSessionWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset
{
    return [[[self class] alloc] initWithAsset:asset preset:preset];
}

- (instancetype)initWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset
{
    if ((self = [self init]))
    {
        _preset = preset;
        _asset = asset;
        _videoOrientation = [asset lf_degressFromVideo];
    }

    return self;
}

- (float)estimatedExportSize
{
    unsigned long audioBitrate = 0;
    unsigned long videoBitrate = 0;
    
    if (self.audioSettings) {
        audioBitrate = [[self.audioSettings objectForKey:AVEncoderBitRateKey] unsignedLongValue];
    } else {
        audioBitrate = [[lf_assetExportAudioConfig() objectForKey:AVEncoderBitRateKey] unsignedLongValue];
    }
    if (self.videoSettings) {
        videoBitrate = [[[self.videoSettings objectForKey:AVVideoCompressionPropertiesKey] objectForKey:AVVideoAverageBitRateKey] unsignedLongValue];
    } else {
        NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoTracks.count > 0) {
            AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
            videoBitrate = [[[lf_assetExportVideoConfig(videoTrack.naturalSize, self.preset) objectForKey:AVVideoCompressionPropertiesKey] objectForKey:AVVideoAverageBitRateKey] unsignedLongValue];
        }
    }
    
    Float64 duration = 0;
    if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration))
    {
        duration = CMTimeGetSeconds(self.timeRange.duration);
    }
    else
    {
        duration = CMTimeGetSeconds(self.asset.duration);
    }
    
    if (audioBitrate > 0 && videoBitrate > 0) {
        //    （音频编码率（KBit为单位）/8 + 视频编码率（KBit为单位）/8）× 影片总长度（秒为单位）= 文件大小（KB为单位）
        float compressedSize = (audioBitrate/1000.0/8.0 + videoBitrate/1000.0/8.0) * duration;
        return compressedSize;
    }
    return 0;
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(void))handler
{
    NSParameterAssert(handler != nil);
    
    _cancelled = NO;
    
    if (!self.outputURL)
    {
        _error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{
                NSLocalizedDescriptionKey: @"Output URL not set"
        }];
        handler();
        return;
    }
    if ([NSFileManager.defaultManager fileExistsAtPath:self.outputURL.path]) {
        [NSFileManager.defaultManager removeItemAtURL:self.outputURL error:nil];
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
        _totalDuration = CMTimeGetSeconds(self.timeRange.duration);
    }
    else
    {
        _totalDuration = CMTimeGetSeconds(self.asset.duration);
    }
    
    self.reader.timeRange = self.timeRange;
    self.writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    self.writer.metadata = self.metadata;
    
    [self _setupAudioUsingTracks:[self.asset tracksWithMediaType:AVMediaTypeAudio]];
    [self _setupVideoUsingTracks:[self.asset tracksWithMediaType:AVMediaTypeVideo]];
    
    if (![_reader startReading]) {
        _error = _reader.error;
        handler();
        return;
    }
    
    if (![_writer startWriting]) {
        _error = _writer.error;
        handler();
        return;
    }
    
    [self.writer startSessionAtSourceTime:self.timeRange.start];
    
    [self beginReadWriteOnAudio];
    [self beginReadWriteOnVideo];
    
    dispatch_group_notify(_dispatchGroup, dispatch_get_main_queue(), ^{
        if (self->_error == nil) {
            self->_error = self.writer.error;
        }
        
        if (self->_error == nil && self.writer.status != AVAssetWriterStatusCancelled) {
            [self.writer finishWritingWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_error = self.writer.error;
                    [self complete];
                });
            }];
        } else {
            [self complete];
        }
    });
}

- (void)_setupAudioUsingTracks:(NSArray *)audioTracks {
    //
    //Audio output
    //
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
}


- (void)_setupVideoUsingTracks:(NSArray *)videoTracks {
    
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
    } else {
        // Just in case this gets reused
        self.videoOutput = nil;
    }
    
    //
    // Video input
    //
    if (self.videoOutput) {
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
}

- (void)beginReadWriteOnAudio {
    if (_audioInput != nil) {
        dispatch_group_enter(_dispatchGroup);
        _needsLeaveAudio = YES;
        __weak typeof(self) wSelf = self;
        [_audioInput requestMediaDataWhenReadyOnQueue:_audioQueue usingBlock:^{
            __strong typeof(self) strongSelf = wSelf;
            BOOL shouldReadNextBuffer = YES;
            while (strongSelf.audioInput.isReadyForMoreMediaData && shouldReadNextBuffer && !strongSelf.cancelled) {
                CMSampleBufferRef audioBuffer = [strongSelf.audioOutput copyNextSampleBuffer];
                
                if (audioBuffer != nil) {
                    shouldReadNextBuffer = [strongSelf.audioInput appendSampleBuffer:audioBuffer];
                    
                    CMTime time = CMSampleBufferGetPresentationTimeStamp(audioBuffer);
                    
                    CFRelease(audioBuffer);
                    
                    [strongSelf _didAppendToInput:strongSelf.audioInput atTime:time];
                } else {
                    shouldReadNextBuffer = NO;
                }
            }
            
            if (!shouldReadNextBuffer) {
                [strongSelf _markInputComplete:strongSelf.audioInput error:nil];
                if (strongSelf.needsLeaveAudio) {
                    strongSelf.needsLeaveAudio = NO;
                    dispatch_group_leave(strongSelf->_dispatchGroup);
                }
            }
        }];
    }
}

- (void)beginReadWriteOnVideo {
    if (_videoInput != nil) {
        dispatch_group_enter(_dispatchGroup);
        _needsLeaveVideo = YES;
        __weak typeof(self) wSelf = self;
        [_videoInput requestMediaDataWhenReadyOnQueue:_videoQueue usingBlock:^{
            BOOL shouldReadNextBuffer = YES;
            __strong typeof(self) strongSelf = wSelf;
            while (strongSelf.videoInput.isReadyForMoreMediaData && shouldReadNextBuffer && !strongSelf.cancelled) {
                
                CMSampleBufferRef videoBuffer = [strongSelf.videoOutput copyNextSampleBuffer];

                if (videoBuffer != nil) {
                    CMTime time = CMSampleBufferGetPresentationTimeStamp(videoBuffer);
                    time = CMTimeSubtract(time, self.timeRange.start);
                    CVPixelBufferRef renderBuffer = NULL;
                    if ([self.delegate respondsToSelector:@selector(assetExportSession:renderFrame:withPresentationTime:toBuffer:)])
                    {
                        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(videoBuffer);
                        CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, self.videoPixelBufferAdaptor.pixelBufferPool, &renderBuffer);
                        if (status == kCVReturnSuccess){
                            [self.delegate assetExportSession:self renderFrame:pixelBuffer withPresentationTime:time toBuffer:renderBuffer];
                        } else {
                            NSLog(@"Failed to create pixel buffer");
                        }
                    }
                    
                    if (renderBuffer) {
                        shouldReadNextBuffer = [self.videoPixelBufferAdaptor appendPixelBuffer:renderBuffer withPresentationTime:time];
                        CVPixelBufferRelease(renderBuffer);
                    }else {
                        shouldReadNextBuffer = [strongSelf.videoInput appendSampleBuffer:videoBuffer];
                    }
                    
                    CFRelease(videoBuffer);
                    
                    [strongSelf _didAppendToInput:strongSelf.videoInput atTime:time];

                } else {
                    shouldReadNextBuffer = NO;
                }
            }
            
            if (!shouldReadNextBuffer) {
                [strongSelf _markInputComplete:strongSelf.videoInput error:nil];

                if (strongSelf.needsLeaveVideo) {
                    strongSelf.needsLeaveVideo = NO;
                    dispatch_group_leave(strongSelf->_dispatchGroup);
                }
            }
        }];
        
    }
}

- (void)_markInputComplete:(AVAssetWriterInput *)input error:(NSError *)error {
    if (_reader.status == AVAssetReaderStatusFailed) {
        _error = _reader.error;
    } else if (error != nil) {
        _error = error;
    }

    if (_writer.status != AVAssetWriterStatusCancelled) {
        [input markAsFinished];
    }
}

- (void)_didAppendToInput:(AVAssetWriterInput *)input atTime:(CMTime)time {
    if (input == _videoInput || _videoInput == nil) {
        float progress = _totalDuration == 0 ? 1 : CMTimeGetSeconds(time) / _totalDuration;
        [self _setProgress:progress];
    }
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

- (void)complete
{
    if (!_cancelled) {
        [self _setProgress:1];
    }
            
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

    dispatch_sync(_videoQueue, ^{
        if (_needsLeaveVideo) {
            _needsLeaveVideo = NO;
            dispatch_group_leave(_dispatchGroup);
        }

        dispatch_sync(_audioQueue, ^{
            if (_needsLeaveAudio) {
                _needsLeaveAudio = NO;
                dispatch_group_leave(_dispatchGroup);
            }
        });

        [_reader cancelReading];
        [_writer cancelWriting];
    });
}

- (void)_setProgress:(float)progress {
    
    void (^doProgress)(void) = ^{
        [self willChangeValueForKey:@"progress"];
        
        self->_progress = progress;
        
        [self didChangeValueForKey:@"progress"];
        
        id<LFAssetExportSessionDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(assetExportSessionDidProgress:)]) {
            [delegate assetExportSessionDidProgress:self];
        }
    };
    
    if ([NSThread isMainThread]) {
        doProgress();
    } else {
        dispatch_async(dispatch_get_main_queue(), doProgress);
    }
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
    self.completionHandler = nil;
}

@end
