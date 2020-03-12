//
//  LFDownloadManager.h
//  LFPhotoBrowserDEMO
//
//  Created by TsanFeng Lam on 2017/12/11.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^lf_progressBlock)(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL *URL);
typedef void(^lf_completeBlock)(NSData * data, NSError *error, NSURL *URL);

@interface LFDownloadInfo : NSObject

@property (nonatomic, assign) NSInteger downloadTimes;
@property (nonatomic, strong) NSURL *downloadURL;

@property (nonatomic, readonly) BOOL reDownload;

@property (nonatomic, copy) lf_progressBlock progress;
@property (nonatomic, copy) lf_completeBlock complete;

+ (instancetype)lf_downloadInfoWithURL:(NSURL *)downloadURL;
@end

@interface LFDownloadManager : NSObject

+ (LFDownloadManager *)shareLFDownloadManager;

/** default YES */
@property (nonatomic, assign) BOOL cacheData;

@property (nonatomic, assign) NSUInteger repeatCountWhenDownloadFailed; // 2
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount; // 5

- (void)lf_requestGetURL:(NSURL *)URL completion:(lf_completeBlock)completion;

- (void)lf_downloadURL:(NSURL *)URL progress:(lf_progressBlock)progress completion:(lf_completeBlock)completion;
- (void)lf_downloadInfo:(LFDownloadInfo *)info progress:(lf_progressBlock)progress completion:(lf_completeBlock)completion;
- (void)lf_downloadCancelInfo:(LFDownloadInfo *)info;
// 终止下载
- (void)lf_cancelWithURL:(NSURL *)URL;
- (void)lf_cancel;

+ (void)lf_clearCached;

- (NSData *)dataFromSandboxWithURL:(NSURL *)URL;

@end
