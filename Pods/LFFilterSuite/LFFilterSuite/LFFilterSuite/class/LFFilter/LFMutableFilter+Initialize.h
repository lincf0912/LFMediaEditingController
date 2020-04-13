//
//  LFMutableFilter+Initialize.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFMutableFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFMutableFilter ()

/**
 Creates and returns a filter containg the given sub LFFilters.
 */
+ (instancetype)filterWithFilters:(NSArray <LFFilter *>*)filters;

@end

NS_ASSUME_NONNULL_END
