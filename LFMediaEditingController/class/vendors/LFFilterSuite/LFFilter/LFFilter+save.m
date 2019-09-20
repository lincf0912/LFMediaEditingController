//
//  LFFilter+save.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter+save.h"

@implementation LFFilter (save)

- (BOOL)writeToFile:(NSURL *__nonnull)fileUrl error:(NSError *__nullable*__nullable)error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToURL:fileUrl options:NSDataWritingAtomic error:error];
}

@end
