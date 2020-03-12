//
//  JRStickerContent+JRGetData.h
//  StickerBooth
//
//  Created by djr on 2020/3/10.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRStickerContent (JRGetData)

- (void)jr_getData:(nullable void(^)(NSData * _Nullable data))completeBlock;

- (void)jr_getImage:(nullable void(^)(UIImage * _Nullable image, BOOL isDegraded))completeBlock;

- (void)jr_getImageAndData:(nullable void(^)(NSData * _Nullable data, UIImage * _Nullable image))completeBlock;

@end

NS_ASSUME_NONNULL_END
