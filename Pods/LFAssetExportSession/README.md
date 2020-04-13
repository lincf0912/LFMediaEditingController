# LFAssetExportSession
视频压缩（体积小，清晰度高）

* 可压缩预设（240p、360p、480p、720p、1080p、2k、4k）。
* 更多进阶压缩方案，可设置videoSettings来实现。
* 框架头文件好像很复杂。实际上调用非常简单。

````
    // 可选压缩预设
    LFAssetExportSession *encoder = [LFAssetExportSession exportSessionWithAsset:asset preset:LFAssetExportSessionPreset720P];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = outPath; // 视频输出路径

    [encoder exportAsynchronouslyWithCompletionHandler:^
    {
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            
            NSLog(@"Video export succeeded. video path:%@", encoder.outputURL);
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
        }
        else
        {
            NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
        }
    }];
````
