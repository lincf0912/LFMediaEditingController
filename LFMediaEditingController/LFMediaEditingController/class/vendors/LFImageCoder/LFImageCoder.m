//
//  LFImageCoder.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/20.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFImageCoder.h"
#import <QuartzCore/QuartzCore.h>

inline static CGAffineTransform LFMEGifView_CGAffineTransformExchangeOrientation(UIImageOrientation imageOrientation, CGSize size)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

#pragma mark - public
CGImageRef LFIC_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size, UIViewContentMode contentMode, UIImageOrientation orientation)
{
    CGImageRef newImage = NULL;
    @autoreleasepool {
        if (!imageRef) return NULL;
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) return NULL;
        
        switch (orientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
            {
                CGFloat tmpWidth = width;
                width = height;
                height = tmpWidth;
            }
                break;
            default:
                break;
        }
        
        if (size.width > 0 && size.height > 0) {
            float verticalRadio = size.height*1.0/height;
            float horizontalRadio = size.width*1.0/width;
            
            
            float radio = 1;
            if (contentMode == UIViewContentModeScaleAspectFill) {
                if(verticalRadio > horizontalRadio)
                {
                    radio = verticalRadio;
                }
                else
                {
                    radio = horizontalRadio;
                }
            } else if (contentMode == UIViewContentModeScaleAspectFit) {
                if(verticalRadio < horizontalRadio)
                {
                    radio = verticalRadio;
                }
                else
                {
                    radio = horizontalRadio;
                }
            } else {
                if(verticalRadio>1 && horizontalRadio>1)
                {
                    radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
                }
                else
                {
                    radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
                }
                
            }
            
            width = roundf(width*radio);
            height = roundf(height*radio);
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        CGAffineTransform transform = LFMEGifView_CGAffineTransformExchangeOrientation(orientation, CGSizeMake(width, height));
        // BGRA8888 (premultiplied) or BGRX8888
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        if (!context) return NULL;
        CGContextConcatCTM(context, transform);
        switch (orientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(context, CGRectMake(0, 0, height, width), imageRef); // decode
                break;
            default:
                CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
                break;
        }
        newImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }
    return newImage;
}

CGImageRef LFIC_CGImageDecodedFromCopy(CGImageRef imageRef)
{
    return LFIC_CGImageScaleDecodedFromCopy(imageRef, CGSizeZero, UIViewContentModeScaleAspectFit, UIImageOrientationUp);
}


CGImageRef LFIC_CGImageDecodedCopy(UIImage *image)
{
    if (!image) return NULL;
    if (image.images.count > 1) {
        return NULL;
    }
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return NULL;
    CGImageRef newImageRef = LFIC_CGImageDecodedFromCopy(imageRef);
    
    return newImageRef;
}

UIImage *LFIC_UIImageDecodedCopy(UIImage *image)
{
    CGImageRef imageRef = LFIC_CGImageDecodedCopy(image);
    if (!imageRef) return image;
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return newImage;
}


