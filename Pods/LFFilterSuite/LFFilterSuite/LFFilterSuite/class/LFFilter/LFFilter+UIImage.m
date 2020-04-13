//
//  LFFilter+UIImage.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter+UIImage.h"
#import "LFContext.h"

@implementation LFFilter (UIImage)

- (UIImage *)UIImageByProcessingUIImage:(UIImage *)image {
    return [self UIImageByProcessingUIImage:image atTime:0];
}

- (UIImage *)UIImageByProcessingUIImage:(UIImage *)uiImage atTime:(CFTimeInterval)time {
    static LFContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [LFContext contextWithType:LFContextTypeDefault options:nil];
    });
    
    CIImage *image = nil;
    
    if (uiImage != nil) {
        if (uiImage.CIImage != nil) {
            image = uiImage.CIImage;
        } else {
            image = [CIImage imageWithCGImage:uiImage.CGImage];
        }
    }
    
    image = [self imageByProcessingImage:image atTime:time];
    
    if (image != nil) {
        CGImageRef cgImage = [context.CIContext createCGImage:image fromRect:image.extent];
        
        UIImage *outputImage = nil;
        if (uiImage != nil) {
            outputImage = [UIImage imageWithCGImage:cgImage scale:uiImage.scale orientation:uiImage.imageOrientation];
        } else {
            outputImage = [UIImage imageWithCGImage:cgImage];
        }
        
        CGImageRelease(cgImage);
        
        return outputImage;
    } else {
        return nil;
    }
}

- (UIImage *__nullable)UIImageByProcessingAnimatedUIImage:(UIImage *__nullable)image
{
    if (image.images.count) {
        NSInteger frameCount = image.images.count;
        NSTimeInterval duration = image.duration;
        NSMutableArray <UIImage *>*outputImages = [NSMutableArray arrayWithCapacity:image.images.count];
        UIImage *outputImage = nil;
        for (NSInteger i=0; i<frameCount; i++) {
            UIImage *img = image.images[i];
            outputImage = [self UIImageByProcessingUIImage:img atTime:i];
            if (outputImage) {
                [outputImages addObject:outputImage];
            }
        }
        if (frameCount == outputImages.count) {
            return [UIImage animatedImageWithImages:outputImages duration:duration];
        } else {
            return [self UIImageByProcessingUIImage:image.images.firstObject];
        }
    } else {
        return [self UIImageByProcessingUIImage:image];
    }
}

@end
