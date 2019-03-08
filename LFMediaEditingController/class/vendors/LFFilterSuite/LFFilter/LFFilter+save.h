//
//  LFFilter+save.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilter (save)

/**
 Write this filter to a specific file.
 This filter can then be restored from this file using [LFFilter filterWithContentsOfUrl:].
 */
- (void)writeToFile:(NSURL *__nonnull)fileUrl error:(NSError *__nullable*__nullable)error;

@end

NS_ASSUME_NONNULL_END
