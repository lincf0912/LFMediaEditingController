//
//  LFContextImageView+private.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/13.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFContextImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFContextImageView ()

- (UIImage *)renderedUIImageInCIImage:(CIImage * __nullable)image;

@end

NS_ASSUME_NONNULL_END
