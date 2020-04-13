//
//  AVAsset+LFMECommon.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "AVAsset+LFMECommon.h"
#import <UIKit/UIKit.h>

@implementation AVAsset (LFMECommon)

- (UIImage *)lf_firstImage:(NSError **)error
{
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);
    return [self lf_firstImageWithSize:size error:error];
}

- (UIImage *)lf_firstImageWithSize:(CGSize)size error:(NSError **)error
{
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.maximumSize = size;
    
    CGImageRef imageRef = NULL;
    CFTimeInterval thumbnailImageTime = 1;
    NSError *thumbnailImageGenerationError = nil;
    imageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, self.duration.timescale) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!imageRef) {
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        if (error) {
            *error = thumbnailImageGenerationError;
        }
        return nil;
    }
    
    { // fixed black background
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        static CGColorSpaceRef colorSpace;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (@available(iOS 9.0, tvOS 9.0, *)) {
                colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
            } else {
                colorSpace = CGColorSpaceCreateDeviceRGB();
            }
        });
        
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
        if (context) {
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // The rect is bounding box of CGImage, don't swap width & height
            CGImageRelease(imageRef);
            
            CGImageRef newImageRef = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            
            UIImage *image = [UIImage imageWithCGImage:newImageRef];
            CGImageRelease(newImageRef);
            
            return image;
        }
    }
    
    UIImage *image = nil;
    if (imageRef) {
        image = [[UIImage alloc]initWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    
    return image;
}

- (CGSize)videoNaturalSize
{
    NSArray *assetVideoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count <= 0)
    {
        NSLog(@"Error reading the transformed video track");
        return CGSizeZero;
    }
    
    // Insert the tracks in the composition's tracks
    AVAssetTrack *track = [assetVideoTracks firstObject];
    
    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    return CGSizeMake(fabs(dimensions.width), fabs(dimensions.height));
}

@end
