//
//  LFDataFilterImageView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterSuiteHeader.h"
#import "FilterSuiteUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFDataFilterImageView : LFFilterGifView

@property (nonatomic, assign) LFFilterNameType type;

/** 数据 */
@property (nonatomic, strong, nullable) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
