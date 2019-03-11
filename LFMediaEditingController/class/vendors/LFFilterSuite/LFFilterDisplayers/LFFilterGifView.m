//
//  LFFilterGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterGifView.h"
#import "LFWeakSelectorTarget.h"

@interface LFFilterGifView ()
{
    CADisplayLink *_displayLink;
    
    NSInteger _index;
    NSInteger _frameCount;
    CGFloat _timestamp;
    CGImageSourceRef _gifSourceRef;
    NSUInteger _loopTimes;
    
    NSTimeInterval _duration;
}
@end

@implementation LFFilterGifView

- (id)init {
    self = [super init];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _autoPlay = YES;
    _duration = 0.1f;
}

- (void)dealloc
{
    [self unsetupDisplayLink];
}

- (void)setImageByUIImage:(UIImage *)image
{
    if (image == nil) {
        [self unsetupDisplayLink];
    }
    if (image.images.count) {
        [super setImageByUIImage:image.images.firstObject];
        _gifImage = image;
        _frameCount = image.images.count;
        _duration = image.duration / image.images.count;
        [self setupDisplayLink];
    } else {
        [super setImageByUIImage:image];
    }
}

- (void)setGifData:(NSData *)gifData
{
    if (_gifData != gifData) {
        _gifData = gifData;
        if (gifData) {
            _gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(gifData), NULL);
            _frameCount = CGImageSourceGetCount(_gifSourceRef);
            [self setupDisplayLink];
            
            /** 处理第一帧的图片 */
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 1, NULL);
            self.CIImageTime = 1;
            self.CIImage = [CIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        } else {
            [self unsetupDisplayLink];
            _gifSourceRef = nil;
            _frameCount = 0;
        }
    }
}

- (void)setAutoPlay:(BOOL)autoPlay
{
    _autoPlay = autoPlay;
    if (autoPlay) {
        [self playGif];
    } else {
        [self stopGif];
    }
}

#pragma mark - option
- (void)stopGif
{
    _displayLink.paused = YES;
}

- (void)playGif
{
    _displayLink.paused = NO;
}

#pragma mark - CADisplayLink

- (void)setupDisplayLink {
    if (_displayLink == nil) {
        LFWeakSelectorTarget *target = [[LFWeakSelectorTarget alloc] initWithTarget:self targetSelector:@selector(displayGif)];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:target selector:target.handleSelector];
        _displayLink.frameInterval = 1;
        
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        if (!_autoPlay) {
            [self stopGif];
        }
    }
}

- (void)unsetupDisplayLink {
    if (_displayLink != nil) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - Gif
- (void)displayGif
{
    size_t sizeMin = MIN(_index+1, _frameCount-1);
    if (sizeMin == SIZE_MAX) {
        //若该Gif文件无法解释为图片，需要立即返回避免内存crash
        NSLog(@"Unable to interpret gif data");
        return;
    }
    
    float nextFrameDuration = [self frameDurationAtIndex:sizeMin ref:_gifSourceRef];
    if (_timestamp < nextFrameDuration) {
        _timestamp = _timestamp+_displayLink.duration;
        return;
    }
    _index += 1;
    if (_index > _frameCount) {
        _loopTimes ++;
        if (_loopCount == _loopTimes) {
            [self stopGif];
        }
    }
    _index = _index % _frameCount;
    
    
    CGImageRef imageRef = nil;
    if (_gifSourceRef) {
        imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
    } else if (_gifImage) {
        imageRef = [[_gifImage.images objectAtIndex:_index] CGImage];
    }
    
    if (imageRef) {
        self.CIImageTime = _index;
        self.CIImage = [CIImage imageWithCGImage:imageRef];
        if (_gifSourceRef) {
            CGImageRelease(imageRef);
        }
    }
    _timestamp = 0.f;
}

- (float)frameDurationAtIndex:(size_t)index ref:(CGImageSourceRef)ref
{
    if (ref) {
        CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
        NSDictionary *dict = (__bridge NSDictionary *)dictRef;
        NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
        NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
        NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
        if (dictRef) CFRelease(dictRef);
        if (unclampedDelayTime.floatValue) {
            return unclampedDelayTime.floatValue;
        }else if (delayTime.floatValue) {
            return delayTime.floatValue;
        }else{
            return _duration;
        }
    } else {
        return _duration;
    }
}

@end
