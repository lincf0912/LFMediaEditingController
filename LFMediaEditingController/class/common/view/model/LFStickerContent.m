//
//  LFStickerContent.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2020/2/25.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import "LFStickerContent.h"

LFStickerContentStringKey const LFStickerContentDefaultSticker = @"LFStickerContentDefaultSticker";
LFStickerContentStringKey const LFStickerContentAllAlbum = @"LFStickerContentAllAlbum";

LFStickerContentStringKey const LFStickerContentCustomAlbum = @"LFStickerContentCustomAlbum";

NSString *LFStickerCustomAlbum(NSString *name)
{
    return [LFStickerContentCustomAlbum stringByAppendingString:name];
}

@implementation LFStickerContent

+ (instancetype)stickerContentWithTitle:(NSString *)title contents:(NSArray *)contents
{
    return [[[self class] alloc] initWithTitle:title contents:contents];
}
- (instancetype)initWithTitle:(NSString *)title contents:(NSArray *)contents
{
    self = [super init];
    if (self) {
        _title = title;
        _contents = contents;
    }
    return self;
}

@end
