//
//  JRStickerContent.m
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/26.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent.h"
#import <Photos/Photos.h>

NSString * const JRStickerContent_content = @"JRStickerContent_content";
NSString * const JRStickerContent_state = @"JRStickerContent_state";

@interface JRStickerContent ()


@end

@implementation JRStickerContent

+ (instancetype)stickerContentWithContent:(id)content
{
    return [[self alloc] initWithContent:content];
}

- (instancetype)initWithContent:(id)content
{
    self = [super init];
    if (self) {
        _content = content;
        _state = JRStickerContentState_None;
        _progress = 0.f;
    }
    return self;
}

- (JRStickerContentType)type
{
    JRStickerContentType _type = JRStickerContentType_Unknow;
    if ([_content isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)_content;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            _type = JRStickerContentType_URLForFile;
        } else {
            _type = JRStickerContentType_URLForHttp;
        }
    } else if ([_content isKindOfClass:[PHAsset class]]) {
        _type = JRStickerContentType_PHAsset;
    }
    return _type;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _content = [dictionary objectForKey:JRStickerContent_content];
        _progress = 0.f;
        _state = [[dictionary objectForKey:JRStickerContent_state] integerValue];
    } return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *muDict = @{}.mutableCopy;
    if (self.content) {
        [muDict setObject:self.content forKey:JRStickerContent_content];
    }
    if (self.state == JRStickerContentState_Downloading) {
        self.state = JRStickerContentState_None;
    }
    [muDict setObject:@(self.state) forKey:JRStickerContent_state];
    return [muDict copy];

}
@end
