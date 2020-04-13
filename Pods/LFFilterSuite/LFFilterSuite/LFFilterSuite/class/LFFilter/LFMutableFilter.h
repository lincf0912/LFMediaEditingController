//
//  LFMutableFilter.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFMutableFilter : LFFilter

/**
 Contains every added sub filters.
 */
@property (readonly, nonatomic) NSArray <LFFilter *>*__nonnull subFilters;

/**
 Add a sub filter. When processing an image, this LFFilter instance will first process the
 image using its attached CIFilter, then it will ask every sub filters added to process the
 given image.
 */
- (void)addSubFilter:(LFFilter *__nonnull)subFilter;

/**
 Remove a sub filter.
 */
- (void)removeSubFilter:(LFFilter *__nonnull)subFilter;

/**
 Remove a sub filter at a given index.
 */
- (void)removeSubFilterAtIndex:(NSUInteger)index;

/**
 Insert a sub filter at a given index.
 */
- (void)insertSubFilter:(LFFilter *__nonnull)subFilter atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
