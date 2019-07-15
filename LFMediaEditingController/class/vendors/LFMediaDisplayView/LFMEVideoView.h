//
//  LFMEVideoView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFMEVideoView : UIView

/**
 The AVAsset used for displaying the video.
 */
@property (nonatomic, strong) AVAsset *__nullable asset;

/**
 The underlying AVPlayerLayer used for displaying the video.
 */
@property (nonatomic, readonly) AVPlayer *__nullable player;;

/**
 Whether this instance is currently playing.
 */
@property (readonly, nonatomic) BOOL isPlaying;

/**
 The actual item duration.
 */
@property (readonly, nonatomic) CMTime itemDuration;

/**
 The total currently loaded and playable time.
 */
@property (readonly, nonatomic) CMTime playableDuration;

@end

NS_ASSUME_NONNULL_END
