//
//  LFText.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/4/5.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFText.h"

@implementation LFText

- (instancetype)init
{
    self = [super init];
    if (self) {
        _usedRect = CGRectNull;
    }
    return self;
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _attributedText = [coder decodeObjectForKey:@"attributedText"];
        _layoutData = [coder decodeObjectForKey:@"layoutData"];
        _usedRect = [coder decodeCGRectForKey:@"usedRect"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.attributedText forKey:@"attributedText"];
    [coder encodeObject:self.layoutData forKey:@"layoutData"];
    [coder encodeCGRect:self.usedRect forKey:@"usedRect"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
