//
//  LFFilter+UIImage.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilter (UIImage)

/**
 Returns a UIImage by processing this filter into the given UIImage
 */
- (UIImage *__nullable)UIImageByProcessingUIImage:(UIImage *__nullable)image atTime:(CFTimeInterval)time;

/**
 Returns a UIImage by processing this filter into the given UIImage
 */
- (UIImage *__nullable)UIImageByProcessingUIImage:(UIImage *__nullable)image;

@end

NS_ASSUME_NONNULL_END
