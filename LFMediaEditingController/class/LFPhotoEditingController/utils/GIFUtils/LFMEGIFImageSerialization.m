//
//  LFMEGIFImageSerialization.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/5/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFMEGIFImageSerialization.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

inline static NSTimeInterval LFMEGIFImageSerialization_CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
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

NSString * const LFME_AnimatedGIFImageErrorDomain = @"com.compuserve.gif.image.error";

__attribute__((overloadable)) NSData * LFME_UIImageGIFRepresentation(UIImage *image) {
    return LFME_UIImageGIFRepresentation(image, 0.0f, 0, nil);
}

__attribute__((overloadable)) NSData * LFME_UIImageGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error) {
    if (!image.images) {
        return nil;
    }
    
    NSDictionary *userInfo = nil;
    {
        size_t frameCount = image.images.count;
        NSTimeInterval frameDuration = (duration <= 0.0 ? image.duration / frameCount : duration / frameCount);
        NSDictionary *frameProperties = @{
                                          (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                                  (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                                                  }
                                          };
        
        NSMutableData *mutableData = [NSMutableData data];
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
        
        NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                                   (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)
                                                   }
                                           };
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
        
        for (size_t idx = 0; idx < image.images.count; idx++) {
            CGImageDestinationAddImage(destination, [[image.images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
        }
        
        BOOL success = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        if (!success) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Could not finalize image destination", nil)
                         };
            
            goto _error;
        }
        
        return [NSData dataWithData:mutableData];
    }
_error: {
    if (error) {
        *error = [[NSError alloc] initWithDomain:LFME_AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return nil;
}
}

__attribute__((overloadable)) NSData * LFME_UIImageGIFRepresentation(UIImage *image, NSArray<NSNumber *> *durations, NSUInteger loopCount, NSError * __autoreleasing *error)
{
    if (!image.images) {
        return nil;
    }
    
    NSDictionary *userInfo = nil;
    {
        size_t frameCount = image.images.count;
        if (frameCount != durations.count) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"The number of images is not equal to the number of durations", nil)
                         };
            
            goto _error;
        }
        
        NSMutableData *mutableData = [NSMutableData data];
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
        
        NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                                   (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)
                                                   }
                                           };
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
        
        NSDictionary *frameProperties = nil;
        for (size_t idx = 0; idx < image.images.count; idx++) {
            frameProperties = @{
                                (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                        (__bridge NSString *)kCGImagePropertyGIFDelayTime: durations[idx]
                                        }
                                };
            
            CGImageDestinationAddImage(destination, [[image.images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
        }
        
        BOOL success = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        if (!success) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Could not finalize image destination", nil)
                         };
            
            goto _error;
        }
        
        return [NSData dataWithData:mutableData];
    }
_error: {
    if (error) {
        *error = [[NSError alloc] initWithDomain:LFME_AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return nil;
}
}


__attribute__((overloadable)) NSData * LFME_UIImagePNGRepresentation(UIImage *image) {
    return LFME_UIImageRepresentation(image, kUTTypePNG, nil);
}

__attribute__((overloadable)) NSData * LFME_UIImageJPEGRepresentation(UIImage *image) {
    return LFME_UIImageRepresentation(image, kUTTypeJPEG, nil);
}

__attribute__((overloadable)) NSData * LFME_UIImageRepresentation(UIImage *image, CFStringRef __nonnull type, NSError * __autoreleasing *error) {
    
    if (!image) {
        return nil;
    }
    NSDictionary *userInfo = nil;
    {
        NSMutableData *mutableData = [NSMutableData data];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, type, 1, NULL);
        
        CGImageDestinationAddImage(destination, [image CGImage], NULL);
        
        BOOL success = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        if (!success) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Could not finalize image destination", nil)
                         };
            
            goto _error;
        }
        
        return [NSData dataWithData:mutableData];
    }
_error: {
    if (error) {
        *error = [[NSError alloc] initWithDomain:LFME_AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return nil;
}
}

#pragma mark - gif durations
__attribute__((overloadable)) NSArray<NSNumber *> * LFME_UIImageGIFDurationsFromData(NSData *data, NSError * __autoreleasing *error) {
    if (!data) {
        return nil;
    }
    
    NSDictionary *userInfo = nil;
    {
        CGImageSourceRef gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        NSInteger frameCount = CGImageSourceGetCount(gifSourceRef);
        if (frameCount) {
            
            NSInteger index = 0;
            NSMutableArray *durations = [NSMutableArray array];
            while (index < frameCount) {
                [durations addObject:@(LFMEGIFImageSerialization_CGImageSourceGetGifFrameDelay(gifSourceRef, index))];
                index ++;
            }
            
            if (gifSourceRef) {
                CFRelease(gifSourceRef);
            }
            
            return [durations copy];
            
        } else {
            if (gifSourceRef) {
                CFRelease(gifSourceRef);
            }
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"This is not image data.", nil)
                         };
            
            goto _error;
        }
    }
    
_error: {
    if (error) {
        *error = [[NSError alloc] initWithDomain:LFME_AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return nil;
}
}
