//
//  LFStickerItem.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/20.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFText.h"
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface LFStickerItem : NSObject

@property (nonatomic, assign, readonly, getter=isMain) BOOL main;

/** image/gif */
@property (nonatomic, strong) UIImage *image;

/** text */
@property (nonatomic, strong) LFText *text;

/** video */
@property (nonatomic, strong) AVAsset *asset;

/** display(image/text) */
- (UIImage *)displayImage;
- (UIImage *)displayImageAtTime:(NSTimeInterval)time;

/** main view */
+ (instancetype)mainWithImage:(UIImage *)image;
+ (instancetype)mainWithVideo:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
