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

/**
 Set the CIImage using an animation UIImage(images)
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

/**
 Returns the rendered UIImage(gif) in its natural size.
 Subclass should not override this method.
 */
- (UIImage *__nullable)renderedAnimatedUIImage;

@end

NS_ASSUME_NONNULL_END
