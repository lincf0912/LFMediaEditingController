//
//  AVAsset+LFMECommon.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (LFMECommon)

- (UIImage *)lf_firstImage:(NSError **)error;
- (UIImage *)lf_firstImageWithSize:(CGSize)size error:(NSError **)error;

- (CGSize)videoNaturalSize;

@end

NS_ASSUME_NONNULL_END
