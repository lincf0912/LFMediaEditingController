//
//  LFMEDelayCancelBlock.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2018/12/20.
//  Copyright © 2018 LamTsanFeng. All rights reserved.
//

#import "LFMECancelBlock.h"

lf_me_dispatch_cancelable_block_t lf_dispatch_block_t(NSTimeInterval delay, void(^block)(void))
{
    __block lf_me_dispatch_cancelable_block_t cancelBlock = nil;
    lf_me_dispatch_cancelable_block_t delayBlcok = ^(BOOL cancel){
        if (!cancel) {
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        }
        if (cancelBlock) {
            cancelBlock = nil;            
        }
    };
    cancelBlock = delayBlcok;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (cancelBlock) {
            cancelBlock(NO);
        }
    });
    return delayBlcok;
}

void lf_me_dispatch_cancel(lf_me_dispatch_cancelable_block_t block)
{
    if (block) {
        block(YES);
    }
}
