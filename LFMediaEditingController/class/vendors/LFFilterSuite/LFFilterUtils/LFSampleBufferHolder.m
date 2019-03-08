//
//  LFSampleBufferHolder.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFSampleBufferHolder.h"

@implementation LFSampleBufferHolder

- (void)dealloc {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
    }
}

- (void)setSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = nil;
    }
    
    _sampleBuffer = sampleBuffer;
    
    if (sampleBuffer != nil) {
        CFRetain(sampleBuffer);
    }
}

+ (LFSampleBufferHolder *)sampleBufferHolderWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    LFSampleBufferHolder *sampleBufferHolder = [LFSampleBufferHolder new];
    
    sampleBufferHolder.sampleBuffer = sampleBuffer;
    
    return sampleBufferHolder;
}

@end
