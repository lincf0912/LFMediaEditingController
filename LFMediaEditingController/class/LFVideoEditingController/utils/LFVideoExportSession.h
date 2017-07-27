//
//  LFVideoExportSession.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/26.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LFVideoExportSession : NSObject

- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithURL:(NSURL *)url;

@property (nonatomic, copy) NSURL *outputURL;
@property (nonatomic) CMTimeRange timeRange;


@property (nonatomic, strong) UIView *overlayView;

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSError *error))handler;
- (void)cancelExport;

@end
