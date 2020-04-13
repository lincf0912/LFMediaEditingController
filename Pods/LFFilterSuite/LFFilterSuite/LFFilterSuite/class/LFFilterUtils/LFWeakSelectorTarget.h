//
//  LFWeakSelectorTarget.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/4.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFWeakSelectorTarget : NSObject

@property (readonly, nonatomic, weak) id target;
@property (readonly, nonatomic) SEL targetSelector;
@property (readonly, nonatomic) SEL handleSelector;

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)targetSelector;

- (BOOL)sendMessageToTarget:(id)param;

@end

NS_ASSUME_NONNULL_END
