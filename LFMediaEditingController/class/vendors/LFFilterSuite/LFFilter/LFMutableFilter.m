//
//  LFMutableFilter.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFMutableFilter.h"
#import "LFFilter+Initialize.h"

@interface LFMutableFilter ()
{
    NSMutableArray <LFFilter *>*_subFilters;
}
@end

@implementation LFMutableFilter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _subFilters = [NSMutableArray new];
        
        self.enabled = YES;
    }
    
    return self;
}

- (void)resetToDefaults {
    [super resetToDefaults];
    
    for (LFFilter *subFilter in _subFilters) {
        [subFilter resetToDefaults];
    }
}

- (BOOL)isEmpty {
    BOOL isEmpty = [super isEmpty];
    
    for (LFFilter *filter in _subFilters) {
        isEmpty &= filter.isEmpty;
    }
    
    return isEmpty;
}

- (CIImage *)imageByProcessingImage:(CIImage *)image atTime:(CFTimeInterval)time {
    if (!self.enabled) {
        return image;
    }
    
    for (LFFilter *filter in _subFilters) {
        image = [filter imageByProcessingImage:image atTime:time];
    }
    
    return [super imageByProcessingImage:image atTime:time];
}


#pragma mark - options

- (void)addSubFilter:(LFFilter *)subFilter {
    [_subFilters addObject:subFilter];
}

- (void)removeSubFilter:(LFFilter *)subFilter {
    [_subFilters removeObject:subFilter];
}

- (void)insertSubFilter:(LFFilter *)subFilter atIndex:(NSUInteger)index {
    [_subFilters insertObject:subFilter atIndex:index];
}

- (void)removeSubFilterAtIndex:(NSUInteger)index {
    [_subFilters removeObjectAtIndex:index];
}

- (NSArray <LFFilter *>*)subFilters {
    return [_subFilters copy];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.enabled = [aDecoder decodeBoolForKey:@"Enabled"];
        
        if ([aDecoder containsValueForKey:@"SubFilters"]) {
            _subFilters = [[aDecoder decodeObjectForKey:@"SubFilters"] mutableCopy];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.enabled forKey:@"Enabled"];
    [aCoder encodeObject:_subFilters forKey:@"SubFilters"];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    LFMutableFilter *filter = [super copyWithZone:zone];
    
    if (filter != nil) {
        filter->_subFilters = [_subFilters mutableCopy];
    }
    
    return filter;
}

#pragma mark - Initialize
+ (instancetype)filterWithFilters:(NSArray *)filters {
    LFMutableFilter *filter = [[self class] emptyFilter];
    
    for (LFFilter *subFilter in filters) {
        [filter addSubFilter:subFilter];
    }
    
    return filter;
}

@end
