//
//  UIView+LFDownloadManager.h
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/28.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LFDownloadImageProgressBlock)(CGFloat progress, NSURL *URL);
typedef void(^LFDownloadImageCompletionBlock)(NSData * data, NSError *error, NSURL *URL);

@interface UIView (LFDownloadManager)

- (void)lf_downloadImageWithURL:(NSURL *)url progress:(LFDownloadImageProgressBlock)progressBlock completed:(LFDownloadImageCompletionBlock)completedBlock;

- (void)lf_downloadCancel;

- (NSData *)dataFromCacheWithURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
