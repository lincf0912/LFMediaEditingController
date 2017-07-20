//
//  LFVideoEdit.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFVideoEdit.h"

@implementation LFVideoEdit

- (instancetype)initWithEditURL:(NSURL *)editURL editFinalURL:(NSURL *)editFinalURL data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _editURL = editURL;
        _editFinalURL = editFinalURL;
        _editData = data;
    }
    return self;
}

- (void)createfirstImage
{
    
}
@end
