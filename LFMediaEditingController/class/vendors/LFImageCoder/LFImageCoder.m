//
//  LFImageCoder.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/20.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFImageCoder.h"
#import <QuartzCore/QuartzCore.h>

CGImageRef newCGImageDecodedFromCopy(CGImageRef imageRef)
{
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    // BGRA8888 (premultiplied) or BGRX8888
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) return NULL;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
}


#pragma mark - public
CGImageRef newCGImageDecodedCopy(UIImage *image)
{
    if (!image) return NULL;
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return NULL;
    CGImageRef newImageRef = newCGImageDecodedFromCopy(imageRef);
    
    return newImageRef;
}

UIImage *newUIImageDecodedCopy(UIImage *image)
{
    CGImageRef imageRef = newCGImageDecodedCopy(image);
    if (!imageRef) return nil;
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return newImage;
}


