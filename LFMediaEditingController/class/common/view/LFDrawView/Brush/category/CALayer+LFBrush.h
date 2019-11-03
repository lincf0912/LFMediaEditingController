//
//  CALayer+LFBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/17.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (LFBrush)

/** 层级（区分不同的画笔所画的图层） */
@property (nonatomic, assign) NSInteger lf_level;

@end

NS_ASSUME_NONNULL_END
