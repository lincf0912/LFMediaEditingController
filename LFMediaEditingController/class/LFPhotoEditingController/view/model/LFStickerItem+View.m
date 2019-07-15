//
//  LFStickerItem+View.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/20.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFStickerItem+View.h"
#import "LFMEGifView.h"
#import "LFMEVideoView.h"

@implementation LFStickerItem (View)

- (UIView *)displayView
{
    if (self.image) {
        LFMEGifView *view = [[LFMEGifView alloc] initWithFrame:(CGRect){CGPointZero, self.displayImage.size}];
        view.gifImage = self.displayImage;
        return view;
    } else if (self.asset) {
        CGSize videoSize = CGSizeZero;
        NSArray *assetVideoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if (assetVideoTracks.count > 0)
        {
            // Insert the tracks in the composition's tracks
            AVAssetTrack *track = [assetVideoTracks firstObject];
            
            CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            videoSize = CGSizeMake(fabs(dimensions.width), fabs(dimensions.height));
        } else {
            NSLog(@"Error reading the transformed video track");
        }
        if (!CGSizeEqualToSize(CGSizeZero, videoSize)) {
            CGSize size = CGSizeZero;
            size.width = [UIScreen mainScreen].bounds.size.width;
            size.height = size.width*videoSize.height/videoSize.width;
            videoSize = size;
        }
        LFMEVideoView *view = [[LFMEVideoView alloc] initWithFrame:(CGRect){CGPointZero, videoSize}];
        view.asset = self.asset;
        return view;
    } else if (self.text) {
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.displayImage.size}];
        view.layer.contents = (__bridge id _Nullable)(self.displayImage.CGImage);
//        view.layer.shadowOpacity = .8;
//        view.layer.shadowRadius = 3.0;
//        view.layer.shadowColor = ([self.textColor isEqual:[UIColor blackColor]]) ? [UIColor whiteColor].CGColor : [UIColor blackColor].CGColor;
//        view.layer.shadowOffset = CGSizeMake(1, 1);
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
//        view.layer.shadowPath = path.CGPath;
        return view;
    }
    NSLog(@"%@ has no displayview available", self);
    return nil;
}

@end
