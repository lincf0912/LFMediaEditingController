//
//  JRStickerContent.h
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/26.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JRStickerContentState) {
    JRStickerContentState_None = 0,
    JRStickerContentState_Downloading,
    JRStickerContentState_Success,
    JRStickerContentState_Fail,
};

typedef NS_ENUM(NSInteger, JRStickerContentType) {
    JRStickerContentType_Unknow = 0,
    JRStickerContentType_URLForHttp,
    JRStickerContentType_URLForFile,
    JRStickerContentType_PHAsset,
};


@interface JRStickerContent : NSObject

/** 内容 */
@property (nonatomic, strong) id content;

/** 进度 */
@property (nonatomic, assign) float progress;

/** 状态 */
@property (nonatomic, assign) JRStickerContentState state;

@property (nonatomic, assign, readonly) JRStickerContentType type;

+ (instancetype)stickerContentWithContent:(id)content;
- (instancetype)initWithContent:(id)content;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
