//
//  LFAssetExportSession.h
//
//  Created by TsanFeng Lam on 2020/4/8.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol LFAssetExportSessionDelegate;


/**
 * An `LFAssetExportSession` object transcodes the contents of an AVAsset source object to create an output
 * of the form described by specified video and audio settings. It implements most of the API of Apple provided
 * `AVAssetExportSession` but with the capability to provide you own video and audio settings instead of the
 * limited set of Apple provided presets.
 *
 * After you have initialized an export session with the asset that contains the source media, video and audio
 * settings, and the output file type (outputFileType), you can start the export running by invoking 
 * `exportAsynchronouslyWithCompletionHandler:`. Because the export is performed asynchronously, this method
 * returns immediately — you can observe progress to check on the progress.
 *
 * The completion handler you supply to `exportAsynchronouslyWithCompletionHandler:` is called whether the export
 * fails, completes, or is cancelled. Upon completion, the status property indicates whether the export has
 * completed successfully. If it has failed, the value of the error property supplies additional information
 * about the reason for the failure.
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LFAssetExportSessionPreset) {
    LFAssetExportSessionPreset240P,
    LFAssetExportSessionPreset360P,
    LFAssetExportSessionPreset480P,
    LFAssetExportSessionPreset540P,
    LFAssetExportSessionPreset720P,
    LFAssetExportSessionPreset1080P,
    LFAssetExportSessionPreset2K, // 1440P
    LFAssetExportSessionPreset4K, // 2160P
};

@interface LFAssetExportSession : NSObject

@property (nonatomic, weak) id<LFAssetExportSessionDelegate> delegate;

/* Indicates the type of the preset with which the LFAssetExportSession was initialized */
@property (nonatomic, assign, readonly) LFAssetExportSessionPreset preset;

/**
 * The asset with which the export session was initialized.
 */
@property (nonatomic, strong, readonly) AVAsset *asset;

/**
 * Indicates whether video composition is enabled for export, and supplies the instructions for video composition.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) AVVideoComposition *videoComposition;

/**
 * Indicates whether non-default audio mixing is enabled for export, and supplies the parameters for audio mixing.
 */
@property (nonatomic, copy) AVAudioMix *audioMix;

/**
 * The type of file to be written by the session.
 *
 * The value is a UTI string corresponding to the file type to use when writing the asset.
 * For a list of constants specifying UTIs for standard file types, see `AV Foundation Constants Reference`.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) NSString *outputFileType;

/**
 * The URL of the export session’s output.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) NSURL *outputURL;

/**
 * The settings used for input video track.
 *
 * The dictionary’s keys are from <CoreVideo/CVPixelBuffer.h>.
 */
@property (nonatomic, copy) NSDictionary *videoOutputSettings;

/**
 * The settings used for encoding the video track.
 *
 * A value of nil specifies that appended output should not be re-encoded.
 * The dictionary’s keys are from <AVFoundation/AVVideoSettings.h>.
 */
@property (nonatomic, copy) NSDictionary *videoSettings;

/**
 * The settings used for encoding the audio track.
 *
 * A value of nil specifies that appended output should not be re-encoded.
 * The dictionary’s keys are from <CoreVideo/CVPixelBuffer.h>.
 */
@property (nonatomic, copy) NSDictionary *audioSettings;

/**
 * The time range to be exported from the source.
 *
 * The default time range of an export session is `kCMTimeZero` to `kCMTimePositiveInfinity`,
 * meaning that (modulo a possible limit on file length) the full duration of the asset will be exported.
 *
 * You can observe this property using key-value observing.
 *
 */
@property (nonatomic, assign) CMTimeRange timeRange;

/**
 * Indicates whether the movie should be optimized for network use.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;

/**
 * The metadata to be written to the output file by the export session.
 */
@property (nonatomic, copy) NSArray *metadata;

/**
 * Describes the error that occurred if the export status is `AVAssetExportSessionStatusFailed`
 * or `AVAssetExportSessionStatusCancelled`.
 *
 * If there is no error to report, the value of this property is nil.
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 Will be set to YES if cancelExport was called
 */
@property (readonly, atomic) BOOL cancelled;

/**
 * The progress of the export on a scale from 0 to 1.
 *
 *
 * A value of 0 means the export has not yet begun, 1 means the export is complete.
 *
 * Unlike Apple provided `AVAssetExportSession`, this property can be observed using key-value observing.
 */
@property (nonatomic, assign, readonly) float progress;

/**
 * The status of the export session.
 *
 * For possible values, see “AVAssetExportSessionStatus.”
 *
 * You can observe this property using key-value observing. (TODO)
 */
@property (nonatomic, assign, readonly) AVAssetExportSessionStatus status;

/**
 * The estimated size(KB) of the export session.
 */
@property (nonatomic, assign, readonly) float estimatedExportSize;

/**
 * Returns an asset export session configured with a specified asset.
 *
 * @param asset The asset you want to export
 * @param preset An enum specifying the type of the preset template for the export.
 * @return An asset export session initialized to export `asset`.
 */
+ (instancetype)exportSessionWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset;

/**
 * Initializes an asset export session with a specified asset.
 *
 * @param asset The asset you want to export
 * @param preset An enum specifying the type of the preset template for the export.
 * @return An asset export session initialized to export `asset`.
 */
- (instancetype)initWithAsset:(AVAsset *)asset preset:(LFAssetExportSessionPreset)preset;

/**
 * Starts the asynchronous execution of an export session.
 *
 * This method starts an asynchronous export operation and returns immediately. status signals the terminal
 * state of the export session, and if a failure occurs, error describes the problem.
 *
 * If internal preparation for export fails, handler is invoked synchronously. The handler may also be called
 * asynchronously, after the method returns, in the following cases:
 *
 * 1. If a failure occurs during the export, including failures of loading, re-encoding, or writing media data to the output.
 * 2. If cancelExport is invoked.
 * 3. After the export session succeeds, having completely written its output to the outputURL.
 *
 * @param handler A block that is invoked when writing is complete or in the event of writing failure.
 */
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(void))handler;

/**
 * Cancels the execution of an export session.
 *
 * You can invoke this method when the export is running.
 */
- (void)cancelExport;

@end


@protocol LFAssetExportSessionDelegate <NSObject>

@optional
- (void)assetExportSessionDidProgress:(LFAssetExportSession *)assetExportSession;

- (BOOL)assetExportSession:(LFAssetExportSession *)assetExportSession renderFrame:(CVPixelBufferRef)renderFrame withPresentationTime:(CMTime)withPresentationTime toBuffer:(CVPixelBufferRef)toBuffer;

@end

NS_ASSUME_NONNULL_END
