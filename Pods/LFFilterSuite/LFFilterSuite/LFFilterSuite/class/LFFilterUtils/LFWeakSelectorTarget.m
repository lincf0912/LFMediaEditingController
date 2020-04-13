//
//  LFWeakSelectorTarget.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/4.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFWeakSelectorTarget.h"

@implementation LFWeakSelectorTarget

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)sel {
    self = [super init];
    
    if (self) {
        _target = target;
        _targetSelector = sel;
    }
    
    return self;
}

- (BOOL)sendMessageToTarget:(id)param {
    id strongTarget = _target;
    
    if (strongTarget != nil) {
        if ([strongTarget respondsToSelector:_targetSelector]) {            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [strongTarget performSelector:_targetSelector withObject:param];
#pragma clang diagnostic pop
        }
        
        return YES;
    }
    
    return NO;
}

- (SEL)handleSelector {
    return @selector(sendMessageToTarget:);
}

@end
