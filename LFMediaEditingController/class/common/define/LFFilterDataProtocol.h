//
//  LFFilterDataProtocol.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2020/2/24.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterSuiteUtils.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LFFilterDataProtocol <NSObject>

@property (nonatomic, assign) LFFilterNameType type;

@end

NS_ASSUME_NONNULL_END
