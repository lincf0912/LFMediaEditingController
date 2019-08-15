//
//  LFMEGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEGifView.h"
#import "LFMEWeakSelectorTarget.h"

@interface LFMEGifView ()
{
    CADisplayLink *_displayLink;
    
    NSInteger _index;
    NSInteger _frameCount;
    CGFloat _timestamp;
    NSUInteger _loopTimes;
    
    NSTimeInterval _duration;
}

@end

@implementation LFMEGifView

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
    _frameCount = 0;
    _duration = 0.1f;
    _loopTimes = 0;
}

- (void)setGifImage:(UIImage *)gifImage
{
    [self freeData];
    _gifImage = gifImage;
    if (gifImage.images.count) {
        _frameCount = gifImage.images.count;
        _duration = gifImage.duration / gifImage.images.count;
        [self setupDisplayLink];
    } else {
        [self unsetupDisplayLink];
        self.layer.contents = (__bridge id _Nullable)(gifImage.CGImage);
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
    
    while (_timestamp >= _duration) {
        _duration -= _duration;
        
        UIImage *image = nil;
        if (_gifImage) {
            image = [_gifImage.images objectAtIndex:_index];
        }
        
        if (image.CGImage) {
            self.layer.contents = (__bridge id _Nullable)(image.CGImage);
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

@end
