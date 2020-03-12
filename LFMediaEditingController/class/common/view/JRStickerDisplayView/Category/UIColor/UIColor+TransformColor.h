//
//  UIColor+TransformColor.h
//  StickerBooth
//
//  Created by djr on 2020/3/6.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TransformColor)

+ (nonnull UIColor *)colorTransformFrom:(nonnull UIColor *)fromColor to:(nonnull UIColor *)toColor progress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
