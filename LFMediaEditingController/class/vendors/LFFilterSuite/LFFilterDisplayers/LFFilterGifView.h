//
//  LFFilterGifView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilterGifView : LFFilterImageView

@property (nonatomic, strong, nullable) NSData *gifData;

@property (nonatomic, readonly, nullable) UIImage *gifImage;
/**
 Set the CIImage using an UIImage(images)
 */
- (void)setImageByUIImage:(UIImage *__nullable)image;

/**
 Whether this instance is auto play.
 */
@property (assign, nonatomic) BOOL autoPlay;

/**
 Number of times gif played.
 */
@property (assign, nonatomic) NSUInteger loopCount;

/**
 Whether this instance play gif.
 */
- (void)playGif;
/**
 Whether this instance stop gif.
 */
- (void)stopGif;

@end

NS_ASSUME_NONNULL_END
