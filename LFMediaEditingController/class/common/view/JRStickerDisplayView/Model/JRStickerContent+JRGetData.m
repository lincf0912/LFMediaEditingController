//
//  JRStickerContent+JRGetData.m
//  StickerBooth
//
//  Created by djr on 2020/3/10.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent+JRGetData.h"
#import "JRConfigTool.h"
#import "LFDownloadManager.h"
#import "JRPHAssetManager.h"
#import "NSData+CompressDecodedImage.h"

@implementation JRStickerContent (JRGetData)

- (void)jr_getData:(nullable void(^)(NSData * _Nullable data))completeBlock
{
    if (completeBlock) {
        if (self.state == JRStickerContentState_Success) {
            switch (self.type) {
                case JRStickerContentType_PHAsset:
                {
                    [JRPHAssetManager jr_GetPhotoDataWithAsset:self.content completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        completeBlock(data);
                    } progressHandler:nil];
                }            
            break;
        case JRStickerContentType_URLForHttp:
        case JRStickerContentType_URLForFile:
            {
                dispatch_queue_t queue = [JRConfigTool shareInstance].concurrentQueue;
                dispatch_async(queue, ^{
                    NSData *resultData = nil;
                    if (self.type == JRStickerContentType_URLForHttp) {
                        resultData = [[LFDownloadManager shareLFDownloadManager] dataFromSandboxWithURL:self.content];
                    } else if (self.type == JRStickerContentType_URLForFile) {
                        resultData = [NSData dataWithContentsOfURL:self.content];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(resultData);
                    });
                });
            }
            break;
        default:
            {
                completeBlock(nil);
            }
            break;
        }
    } else {
        completeBlock(nil);
    }
    }
}

- (void)jr_getImage:(nullable void(^)(UIImage * _Nullable image, BOOL isDegraded))completeBlock
{
    if (completeBlock) {
        if (self.state == JRStickerContentState_Success) {
            switch (self.type) {
                case JRStickerContentType_PHAsset:
                {
                    [JRPHAssetManager jr_GetPhotoWithAsset:self.content photoWidth:CGRectGetWidth([UIScreen mainScreen].bounds) completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        completeBlock(result, isDegraded);
                    } progressHandler:nil];
                }
                    break;
                case JRStickerContentType_URLForHttp:
                case JRStickerContentType_URLForFile:
                {
                    dispatch_queue_t queue = [JRConfigTool shareInstance].concurrentQueue;
                    dispatch_async(queue, ^{
                        NSData *resultData = nil;
                        if (self.type == JRStickerContentType_URLForHttp) {
                            resultData = [[LFDownloadManager shareLFDownloadManager] dataFromSandboxWithURL:self.content];
                        } else if (self.type == JRStickerContentType_URLForFile) {
                            resultData = [NSData dataWithContentsOfURL:self.content];
                        }
                        CGFloat maxLine = MAX(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
                        UIImage *image = [resultData dataDecodedImageWithSize:CGSizeMake(maxLine, maxLine) mode:UIViewContentModeScaleAspectFit];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(image, NO);
                        });
                    });
                }
                    break;
                default:
                {
                    completeBlock(nil, NO);
                }
                    break;
            }
        } else {
            completeBlock(nil, NO);
        }
    }

}

- (void)jr_getImageAndData:(nullable void(^)(NSData * _Nullable data, UIImage * _Nullable image))completeBlock
{
    if (!completeBlock) return;
    
    __block NSData *resultData = nil;
    __block UIImage *resultImage = nil;
    
    [self jr_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
        if (!isDegraded) {
            resultImage = image;
            if (resultImage && resultData) {
                completeBlock(resultData, resultImage);
            }
        }
    }];
    
    [self jr_getData:^(NSData * _Nullable data) {
        resultData = data;
        if (resultImage && resultData) {
            completeBlock(resultData, resultImage);
        }
    }];

        
}

@end
