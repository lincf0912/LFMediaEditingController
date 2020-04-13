//
//  LFFilterVideoView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/4.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilterVideoView : LFFilterImageView

/**
 The underlying AVPlayerLayer used for displaying the video.
 */
@property (nonatomic, strong)  AVPlayer *__nullable player;

/**
 If true, the player will figure out an affine transform so the video best fits the screen. The resulting video may not be in the correct device orientation though.
 For example, if the video is in landscape and the current device orientation is in portrait mode,
 with this property enabled the video will be rotated so it fits the entire screen. This avoid
 showing the black border on the sides. If your app supports multiple orientation, you typically
 wouldn't want this feature on.
 */
@property (assign, nonatomic) BOOL autoRotate;

/**
 Whether this instance displays default rendered video
 */
@property (assign, nonatomic) BOOL shouldSuppressPlayerRendering;

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
