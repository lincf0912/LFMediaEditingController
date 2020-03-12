//
//  UIView+LFDownloadManager.m
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/28.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "UIView+LFDownloadManager.h"
#import "LFDownloadManager.h"
#import <objc/runtime.h>

static const char * LFDownloadViewInfoKey = "LFDownloadViewInfoKey";

@implementation UIView (LFDownloadManager)

- (LFDownloadInfo *)lf_downloadInfo
{
    return objc_getAssociatedObject(self, LFDownloadViewInfoKey);
}

- (void)setLf_downloadInfo:(LFDownloadInfo *)lf_downloadInfo
{
    objc_setAssociatedObject(self, LFDownloadViewInfoKey, lf_downloadInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lf_downloadImageWithURL:(NSURL *)url progress:(LFDownloadImageProgressBlock)progressBlock completed:(LFDownloadImageCompletionBlock)completedBlock
{
    [self lf_downloadCancel];
    
    LFDownloadInfo *info = [LFDownloadInfo lf_downloadInfoWithURL:url];
    self.lf_downloadInfo = info;
    
    [[LFDownloadManager shareLFDownloadManager] lf_downloadInfo:info progress:^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL *downloadURL) {
        if (progressBlock && [self.lf_downloadInfo.downloadURL.absoluteString isEqualToString:downloadURL.absoluteString]) {
            float progress = totalBytesWritten*1.00f/totalBytesExpectedToWrite*1.00f;
            progressBlock(progress, downloadURL);
        }
    } completion:^(NSData *downloadData, NSError *error, NSURL *downloadURL) {
        if (completedBlock && [self.lf_downloadInfo.downloadURL.absoluteString isEqualToString:downloadURL.absoluteString]) {
            self.lf_downloadInfo = nil;
            completedBlock(downloadData, error, downloadURL);
        }
    }];
}

- (void)lf_downloadCancel
{
    [[LFDownloadManager shareLFDownloadManager] lf_downloadCancelInfo:self.lf_downloadInfo];
    self.lf_downloadInfo = nil;
}

- (NSData *)dataFromCacheWithURL:(NSURL *)URL
{
    return [[LFDownloadManager shareLFDownloadManager] dataFromSandboxWithURL:URL];
}



@end
