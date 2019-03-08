//
//  LFVideoExportSession.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/26.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LFFilter.h"

@interface LFVideoExportSession : NSObject

/** 初始化 */
- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithURL:(NSURL *)url;

/** 输出路径 */
@property (nonatomic, copy) NSURL *outputURL;
/** 视频剪辑 */
@property (nonatomic, assign) CMTimeRange timeRange;
/** 是否需要原音频 default is YES */
@property (nonatomic, assign) BOOL isOrignalSound;
/** 添加音频 */
@property (nonatomic, strong, nullable) NSArray <NSURL *>*audioUrls;
/** 水印层 (overlayView的大小必须与视频大小比例相同，否则会被拉伸。) */
@property (nonatomic, strong, nullable) UIView *overlayView;
/** 滤镜 */
@property (nonatomic, strong, nullable) LFFilter *filter;

/** 处理视频 */
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSError *error))handler;
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSError *error))handler progress:(void (^)(float progress))progress;
- (void)cancelExport;

@end
