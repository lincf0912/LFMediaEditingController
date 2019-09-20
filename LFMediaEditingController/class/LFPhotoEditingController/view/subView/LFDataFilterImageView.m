//
//  LFDataFilterImageView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFDataFilterImageView.h"

NSString *const kLFDataFilterImageViewData = @"LFDataFilterImageViewData";

@implementation LFDataFilterImageView

- (void)setType:(LFFilterNameType)type
{
    _type = type;
    self.filter = lf_filterWithType(type);
}

#pragma mark  - 数据
- (NSDictionary * __nullable)data
{
    if (self.type != LFFilterNameType_None) {
        return @{kLFDataFilterImageViewData:@(self.type)};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    self.type = [data[kLFDataFilterImageViewData] integerValue];
}

@end
