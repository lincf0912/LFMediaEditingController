//
//  UIImage+Format.m
//  MEMobile
//
//  Created by LamTsanFeng on 16/9/23.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "UIImage+LF_Format.h"
#import <ImageIO/ImageIO.h>

#define _FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))
#define _TWO_CC(c1,c2) ((uint16_t)(((c2) << 8) | (c1)))

LFImageType LFImageDetectType(CFDataRef data) {
    if (!data) return LFImageType_Unknow;
    uint64_t length = CFDataGetLength(data);
    if (length < 16) return LFImageType_Unknow;
    
    const char *bytes = (char *)CFDataGetBytePtr(data);
    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
        case _FOUR_CC(0x4D, 0x4D, 0x00, 0x2A): { // big endian TIFF
            return LFImageType_TIFF;
        } break;
            
        case _FOUR_CC(0x49, 0x49, 0x2A, 0x00): { // little endian TIFF
            return LFImageType_TIFF;
        } break;
            
        case _FOUR_CC(0x00, 0x00, 0x01, 0x00): { // ICO
            return LFImageType_ICO;
        } break;
            
        case _FOUR_CC('i', 'c', 'n', 's'): { // ICNS
            return LFImageType_ICNS;
        } break;
            
        case _FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return LFImageType_GIF;
        } break;
            
        case _FOUR_CC(0x89, 'P', 'N', 'G'): {  // PNG
            uint32_t tmp = *((uint32_t *)(bytes + 4));
            if (tmp == _FOUR_CC('\r', '\n', 0x1A, '\n')) {
                return LFImageType_PNG;
            }
        } break;
            
        case _FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            uint32_t tmp = *((uint32_t *)(bytes + 8));
            if (tmp == _FOUR_CC('W', 'E', 'B', 'P')) {
                return LFImageType_WebP;
            }
        } break;
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case _TWO_CC('B', 'A'):
        case _TWO_CC('B', 'M'):
        case _TWO_CC('I', 'C'):
        case _TWO_CC('P', 'I'):
        case _TWO_CC('C', 'I'):
        case _TWO_CC('C', 'P'): { // BMP
            return LFImageType_BMP;
        }
        case _TWO_CC(0xFF, 0x4F): { // JPEG2000
            return LFImageType_JPEG2000;
        }
    }
    if (memcmp(bytes,"\377\330\377",3) == 0) return LFImageType_JPEG;
    if (memcmp(bytes + 4, "\152\120\040\040\015", 5) == 0) return LFImageType_JPEG2000;
    return LFImageType_Unknow;
}

@implementation UIImage (LF_Format)

+ (instancetype)LF_imageWithImagePath:(NSString *)imagePath
{
    return [self LF_imageWithImagePath:imagePath error:nil];
}

+ (instancetype)LF_imageWithImagePath:(NSString *)imagePath error:(NSError **)error
{
    if (imagePath.length == 0) return nil;
    NSError *dataError = nil;
    NSData *imgData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:&dataError];
    if (dataError != nil) {
        NSLog(@"%@", dataError.localizedDescription);
        if (error) {
            *error = dataError;
        }
        return nil;
    }
    
    return [self LF_imageWithImageData:imgData];
}

+ (instancetype)LF_imageWithImageData:(NSData *)imgData
{
    LFImageType imageType = LFImageDetectType((__bridge CFDataRef)imgData);
    
    UIImage *image = nil;
    switch (imageType) {
        case LFImageType_GIF:
            image = [self sd_animatedGIFWithData:imgData];
            break;
//        case LFImageType_WebP:
//            image = [self sd_imageWithWebPData:imgData];
//            break;
        default:
            image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
            break;
    }
    return image;
}

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self sd_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

@end
