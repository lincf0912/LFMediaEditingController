//
//  LFMEGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEGifView.h"
#import "LFMEWeakSelectorTarget.h"

inline static NSTimeInterval LFMEGifView_CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    if (dictRef) CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        frameDuration = unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        frameDuration = delayTime.floatValue;
    }else{
        frameDuration = .1;
    }
    return frameDuration;
}

@interface LFMEGifView ()
{
    CADisplayLink *_displayLink;
    
    NSInteger _index;
    NSInteger _frameCount;
    CGFloat _timestamp;
    NSUInteger _loopTimes;
    
    CGImageSourceRef _gifSourceRef;
    
    NSTimeInterval _duration;
}

@property (readonly, nonatomic, nullable) NSArray<NSNumber *> * durations;

@end

@implementation LFMEGifView

@synthesize image = _image;

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _autoPlay = YES;
    _duration = 0.1f;
}

- (void)dealloc
{
    [self freeData];
    [self unsetupDisplayLink];
}

- (void)freeData
{
    [self unsetupDisplayLink];
    _image = nil;
    _data = nil;
    _frameCount = 0;
    _duration = 0.1f;
    _loopTimes = 0;
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
    }
    _durations = nil;
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        [self freeData];
        _image = image;
        if (_image.images.count) {
            _frameCount = _image.images.count;
            _duration = _image.duration / _image.images.count;
            [self setupDisplayLink];
        } else {
            [self unsetupDisplayLink];
            self.layer.contents = (__bridge id _Nullable)(_image.CGImage);
        }
    }
}

- (UIImage *)image
{
    if (_image == nil) {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < _frameCount; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(_gifSourceRef, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [_durations[i] floatValue];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * _frameCount;
        }
        
        return [UIImage animatedImageWithImages:images duration:duration];
    }
    return _image;
}

- (void)setData:(NSData *)data
{
    if (_data != data) {
        [self freeData];
        _data = data;
        if (data) {
            _gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
            _frameCount = CGImageSourceGetCount(_gifSourceRef);
            
            if (_frameCount) {
                NSInteger index = 0;
                NSMutableArray *durations = [NSMutableArray array];
                while (index < _frameCount) {
                    [durations addObject:@(LFMEGifView_CGImageSourceGetGifFrameDelay(_gifSourceRef, index))];
                    index ++;
                }
                _durations = [durations copy];
            }
            
            [self setupDisplayLink];
        } else {
            [self unsetupDisplayLink];
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
    if (_displayLink == nil && _frameCount > 1) {
        LFMEWeakSelectorTarget *target = [[LFMEWeakSelectorTarget alloc] initWithTarget:self targetSelector:@selector(displayGif)];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:target selector:target.handleSelector];
        
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
        [self freeData];
        [self unsetupDisplayLink];
        return;
    }
    
    _timestamp += fmin(_displayLink.duration, 1);
    
    while (_timestamp >= [self frameDurationAtIndex:_index]) {
        _timestamp -= [self frameDurationAtIndex:_index];
        
        CGImageRef imageRef = nil;
        if (_gifSourceRef) {
            imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
        } else if (_image) {
            imageRef = [[_image.images objectAtIndex:_index] CGImage];
        }
        
        if (imageRef) {
            self.layer.contents = (__bridge id _Nullable)(imageRef);
        }
        if (_gifSourceRef && imageRef) {
            CGImageRelease(imageRef);
        }
        
        _index += 1;
        if (_index == _frameCount) {
            _index = 0;
            if (_loopCount == ++_loopTimes) {
                [self stopGif];
                return;
            }
        }
    }
}

- (float)frameDurationAtIndex:(NSUInteger)index
{
    if (_durations) {
        return _durations[index%_durations.count].floatValue;
    } else {
        return _duration;
    }
}

@end
