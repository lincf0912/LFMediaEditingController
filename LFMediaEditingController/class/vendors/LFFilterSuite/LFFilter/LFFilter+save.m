//
//  LFFilter+save.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter+save.h"

@implementation LFFilter (save)

- (void)writeToFile:(NSURL *)fileUrl error:(NSError *__autoreleasing *)error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToURL:fileUrl options:NSDataWritingAtomic error:error];
}

@end
