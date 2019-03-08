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
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.maximumSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);
    
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

@end
