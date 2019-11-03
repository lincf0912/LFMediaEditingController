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

/** 强制缓存对象，不会因数量超出负荷而自动释放 */
- (void)setForceObject:(id)obj forKey:(id)key;

@end

NS_ASSUME_NONNULL_END
