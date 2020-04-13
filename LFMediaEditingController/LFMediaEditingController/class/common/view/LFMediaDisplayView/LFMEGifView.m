//
//  LFMEGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEGifView.h"
#import "LFMEWeakSelectorTarget.h"
#import <ImageIO/ImageIO.h>
#import "LFImageCoder.h"

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

inline static UIImageOrientation LFMEGifView_UIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

@interface LFMEGifView ()
{
    CADisplayLink *_displayLink;
    
    NSInteger _index;
    NSInteger _frameCount;
    CGFloat _timestamp;
    
    CGImageSourceRef _gifSourceRef;
    
    NSTimeInterval _duration;
}

@property (readonly, nonatomic, nullable) NSArray<NSNumber *> * durations;

@property (readonly, nonatomic, nullable) NSMutableDictionary<NSNumber *, id> *imageRefs;

@property (nonatomic, assign) UIImageOrientation orientation;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

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
    _duration = 0.1f;
    _imageRefs = [NSMutableDictionary dictionary];
    _orientation = UIImageOrientationUp;
    _serialQueue = dispatch_queue_create("LFMEGifViewSerial", DISPATCH_QUEUE_SERIAL);
}

- (void)dealloc
{
    [self freeData];
    [self unsetupDisplayLink];
}

- (void)freeData
{
    [self unsetupDisplayLink];
    _orientation = 0;
    _image = nil;
    _data = nil;
    _frameCount = 0;
    _duration = 0.1f;
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = NULL;
    }
    _index = 0;
    _timestamp = 0;
    _durations = nil;
    
    for (id object in self.imageRefs) {
        CGImageRef imageRef = (__bridge CGImageRef)object;
        CGImageRelease(imageRef);
    }
    [self.imageRefs removeAllObjects];
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        [self freeData];
        _image = image;
        if (image) {
            _orientation = image.imageOrientation;
            if (_image.images.count > 1) {
                _frameCount = _image.images.count;
                _duration = _image.duration / _image.images.count;
                [self setupDisplayLink];
            } else {
                [self unsetupDisplayLink];
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                UIImageOrientation orientation = self.orientation;
                dispatch_async(self.serialQueue, ^{
                    CGImageRef decodeImageRef = LFIC_CGImageScaleDecodedFromCopy(image.CGImage, size, mode, orientation);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.layer.contents = (__bridge id _Nullable)(decodeImageRef);
                        if (decodeImageRef) {
                            CGImageRelease(decodeImageRef);
                        }
                    });
                });
            }
        } else {
            [self unsetupDisplayLink];
        }
    }
}

- (UIImage *)image
{
    if (_image == nil) {
        
        if (self.data) {
            if (_frameCount > 1) {
                NSMutableArray *images = [NSMutableArray array];
                NSTimeInterval duration = 0.0f;
                
                for (size_t i = 0; i < _frameCount; i++) {
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, i, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                    if (!imageRef) {
                        continue;
                    }
                    
                    duration += [_durations[i] floatValue];
                    
                    [images addObject:[UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:self.orientation]];
                    
                    CGImageRelease(imageRef);
                }
                
                if (!duration) {
                    duration = (1.0f / 10.0f) * _frameCount;
                }
                
                _image = [UIImage animatedImageWithImages:images duration:duration];
            } else {
                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 0, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                CGImageRef decodeImageRef = LFIC_CGImageDecodedFromCopy(imageRef);
                if (imageRef) {
                    CGImageRelease(imageRef);
                }
                UIImage *image = [UIImage imageWithCGImage:decodeImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                if (decodeImageRef) {
                    CGImageRelease(decodeImageRef);
                }
                if (image == nil) {
                    image = [UIImage imageWithData:self.data scale:[UIScreen mainScreen].scale];
                }
                _image = image;
            }
        }
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
            
            //exifInfo 包含了很多信息,有兴趣的可以打印看看,我们只需要Orientation这个字段
            CFDictionaryRef exifInfo = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, 0,NULL);
            
            //判断Orientation这个字段,如果图片经过PS等处理,exif信息可能会丢失
            if(CFDictionaryContainsKey(exifInfo, kCGImagePropertyOrientation)){
                CFNumberRef orientation = CFDictionaryGetValue(exifInfo, kCGImagePropertyOrientation);
                NSInteger orientationValue = 0;
                CFNumberGetValue(orientation, kCFNumberIntType, &orientationValue);
                _orientation = LFMEGifView_UIImageOrientationFromEXIFValue(orientationValue);
            }
            CFRelease(exifInfo);
            
            
            if (_frameCount > 1) {
                NSInteger index = 0;
                NSMutableArray *durations = [NSMutableArray array];
                while (index < _frameCount) {
                    [durations addObject:@(LFMEGifView_CGImageSourceGetGifFrameDelay(_gifSourceRef, index))];
                    index ++;
                }
                _durations = [durations copy];
                [self setupDisplayLink];
            } else {
                [self unsetupDisplayLink];
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                UIImageOrientation orientation = self.orientation;
                dispatch_async(self.serialQueue, ^{
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(self->_gifSourceRef, 0, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                    CGImageRef decodeImageRef = LFIC_CGImageScaleDecodedFromCopy(imageRef, size, mode, orientation);
                    if (imageRef) {
                        CGImageRelease(imageRef);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.layer.contents = (__bridge id _Nullable)(decodeImageRef);
                        if (decodeImageRef) {
                            CGImageRelease(decodeImageRef);
                        }
                    });
                });
            }
        } else {
            [self unsetupDisplayLink];
        }
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
        
        [self playGif];
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
        
        CGImageRef imageRef = (__bridge CGImageRef)([self.imageRefs objectForKey:@(_index)]);
        if (imageRef == NULL) {
            if (_gifSourceRef) {
                imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
            } else if (_image) {
                imageRef = [[_image.images objectAtIndex:_index] CGImage];
            }
            if (imageRef) {
                CGImageRef decodeImageRef = LFIC_CGImageScaleDecodedFromCopy(imageRef, self.frame.size, self.contentMode, self.orientation);
                if (_gifSourceRef && imageRef) {
                    CGImageRelease(imageRef);
                }
                [self.imageRefs setObject:(__bridge id _Nullable)(decodeImageRef) forKey:@(_index)];
                imageRef = decodeImageRef;
            }
        }
        
        if (imageRef) {
            self.layer.contents = (__bridge id _Nullable)(imageRef);
        }
        
        
        _index += 1;
        if (_index == _frameCount) {
            _index = 0;
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
