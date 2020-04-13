//
//  LFDataFilterVideoView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFDataFilterVideoView.h"

NSString *const kLFDataFilterVideoViewData = @"LFDataFilterVideoViewData";

@implementation LFDataFilterVideoView

- (void)setType:(LFFilterNameType)type
{
    _type = type;
    self.filter = lf_filterWithType(type);
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.type != LFFilterNameType_None) {
        return @{kLFDataFilterVideoViewData:@(self.type)};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    self.type = [data[kLFDataFilterVideoViewData] integerValue];
}
@end
