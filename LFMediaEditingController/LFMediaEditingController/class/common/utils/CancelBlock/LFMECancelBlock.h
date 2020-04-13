//
//  LFMEDelayCancelBlock.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2018/12/20.
//  Copyright © 2018 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^lf_me_dispatch_cancelable_block_t)(BOOL cancel);

OBJC_EXTERN lf_me_dispatch_cancelable_block_t lf_dispatch_block_t(NSTimeInterval delay, void(^block)(void));

OBJC_EXTERN void lf_me_dispatch_cancel(lf_me_dispatch_cancelable_block_t block);

