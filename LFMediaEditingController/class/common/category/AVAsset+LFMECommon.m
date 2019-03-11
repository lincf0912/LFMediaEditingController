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
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 1;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, self.duration.timescale) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef) {
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        if (error) {
            *error = thumbnailImageGenerationError;
        }
    }
    
    return thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
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
