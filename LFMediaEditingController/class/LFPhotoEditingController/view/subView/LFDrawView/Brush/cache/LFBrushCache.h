//
//  LFBrushCache.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFBrushCache : NSCache

+ (instancetype)share;
+ (void)free;

@end

NS_ASSUME_NONNULL_END
