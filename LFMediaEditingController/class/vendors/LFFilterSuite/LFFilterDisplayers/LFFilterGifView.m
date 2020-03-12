//
//  LFFilterGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterGifView.h"
#import "LFWeakSelectorTarget.h"
#import "LFContextImageView+private.h"

inline static NSTimeInterval LFFilterGifView_CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
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

@property (nonatomic, strong) UIImage *gifImage;

@end

@implementation LFFilterGifView

- (void)commonInit
{
    [super commonInit];
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
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = NULL;
    }
    _index = 0;
    _timestamp = 0;
    _gifData = nil;
    _frameCount = 0;
    _duration = 0.1f;
    _loopTimes = 0;
}

- (void)setImageByUIImage:(UIImage *)image
{
    [self freeData];
    if (image.images.count) {
        [super setImageByUIImage:image.images.firstObject];
        _gifImage = image;
        _frameCount = image.images.count;
        _duration = image.duration / image.images.count;
        [self setupDisplayLink];
    } else {
        [self unsetupDisplayLink];
        [super setImageByUIImage:image];
    }
}

- (void)setImageByUIImage:(UIImage *__nullable)image durations:(NSArray <NSNumber *> *__nullable)durations
{
    _durations = [durations copy];
    [self setImageByUIImage:image];
}

- (void)setGifData:(NSData *)gifData
{
    if (_gifData != gifData) {
        [self freeData];
        _gifData = gifData;
        if (gifData) {
            _gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(gifData), NULL);
            _frameCount = CGImageSourceGetCount(_gifSourceRef);
            
            if (_frameCount) {
                NSInteger index = 0;
                NSMutableArray *durations = [NSMutableArray array];
                while (index < _frameCount) {
                    [durations addObject:@(LFFilterGifView_CGImageSourceGetGifFrameDelay(_gifSourceRef, index))];
                    index ++;
                }
                _durations = [durations copy];
            }
            
            /** 处理第一帧的图片 */
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 0, NULL);
            self.CIImageTime = 1;
            self.CIImage = [CIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
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

- (UIImage *__nullable)renderedAnimatedUIImage
{
    NSMutableArray <UIImage *>*returnedImages = [NSMutableArray arrayWithCapacity:_frameCount];
    CGImageRef imageRef = nil;
    UIImage *returnedImage = nil;
    for (NSInteger i=0; i<_frameCount; i++) {
        if (_gifSourceRef) {
            imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, i, NULL);
        } else if (_gifImage) {
            imageRef = [[_gifImage.images objectAtIndex:i] CGImage];
        }
        CIImage *image = nil;
        if (imageRef) {
            image = [CIImage imageWithCGImage:imageRef];
            if (_gifSourceRef) {
                CGImageRelease(imageRef);
            }
        }
        
        if (image != nil) {
            if (self.filter != nil) {
                image = [self.filter imageByProcessingImage:image atTime:i];
            }
        }
        
        returnedImage = [self renderedUIImageInCIImage:image];
        if (returnedImage) {
            [returnedImages addObject:returnedImage];
        }
    }
    
    if (_frameCount > 0 && returnedImages.count == _frameCount) {
        /** gif */
        if (_durations) {
            NSTimeInterval duration = 0;
            for (NSNumber *d in _durations) {
                duration += d.floatValue;
            }
            return [UIImage animatedImageWithImages:returnedImages duration:duration];
        } else {
            return [UIImage animatedImageWithImages:returnedImages duration:_duration*_frameCount];
        }
    } else {
        if (_gifSourceRef) {
            imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 0, NULL);
        } else if (_gifImage) {
            imageRef = [[_gifImage.images objectAtIndex:0] CGImage];
        }
        CIImage *image = nil;
        if (imageRef) {
            image = [CIImage imageWithCGImage:imageRef];
            if (_gifSourceRef) {
                CGImageRelease(imageRef);
            }
        }
        
        if (image != nil) {
            if (self.filter != nil) {
                image = [self.filter imageByProcessingImage:image atTime:0];
            }
            /** first frame image */
            return [self renderedUIImageInCIImage:image];
        } else {
            /** display image */
            return [self renderedUIImage];
        }
    }
}

#pragma mark - CADisplayLink

- (void)setupDisplayLink {
    
    size_t sizeMin = MIN(_index+1, _frameCount-1);
    if (sizeMin == SIZE_MAX) {
        //若该Gif文件无法解释为图片，需要立即返回避免内存crash
        NSLog(@"Unable to interpret gif data");
        [self freeData];
        return;
    }
    
    if (_displayLink == nil && _frameCount > 1) {
        LFWeakSelectorTarget *target = [[LFWeakSelectorTarget alloc] initWithTarget:self targetSelector:@selector(displayGif)];
        
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
    _timestamp += fmin(_displayLink.duration, 1);
    
    while (_timestamp >= [self frameDurationAtIndex:_index]) {
        _timestamp -= [self frameDurationAtIndex:_index];
        _index = MIN(_index, _frameCount - 1);
        
        CGImageRef imageRef = nil;
        if (_gifSourceRef) {
            imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
            if (imageRef) {
                self.CIImageTime = _index+1;
                self.CIImage = [CIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
        } else if (_gifImage) {
            imageRef = [[_gifImage.images objectAtIndex:_index] CGImage];
            if (imageRef) {
                self.CIImageTime = _index+1;
                self.CIImage = [CIImage imageWithCGImage:imageRef];
            }
        }
        if (++_index >= _frameCount) {
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
