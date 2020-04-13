# LFFilterSuite

滤镜套件，使用滤镜修饰图片或视频。

* 代码来源于[SCRecorder](https://github.com/rFlex/SCRecorder)项目，向该项目的开发人员致敬并感谢。  
* 本套件降低了使用的复杂性。
* 重命名类名，避免冲突。
* 新增对超大图片的支持。
* 新增可以使用UIKit。
* 重写导出视频的实现逻辑（体积小、不模糊）。

## 大图片的使用
将属性LFContextImageView.contextType = LFContextTypeLargeImage; 即可。

## 套件使用
1. `#import "LFFilterSuiteHeader.h"`
2. 滤镜展示

	2.1. 使用LFFilterImageView代替UIImageView。
	
	 ````
	 LFFilterImageView *imageView = [[LFFilterImageView alloc] initWithFrame:self.bounds];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[imageView setImageByUIImage:image];
	// 滤镜
	imageView.filter = [LFFilter filterWithCIFilterName:@"CIPhotoEffectChrome"];
	[self addSubview:imageView];
	 ````
	2.2. 使用LFFilterVideoView代替AVPlayerLayer。
	
		
	 ````
	LFFilterVideoView *videoView = [[LFFilterVideoView alloc] initWithFrame:self.bounds];
	videoView.contentMode = UIViewContentModeScaleAspectFit;
	/** 第一帧图片 */
	[videoView setImageByUIImage:image];
	/** 关联视频播放 */
	[videoView setPlayer:player];
	// 滤镜
	videoView.filter = [LFFilter filterWithCIFilterName:@"CIPhotoEffectChrome"];
	[self addSubview:videoView];
	 ````
	 2.3.使用LFFilterGifView代替UIImageView(GIF)。
	 
	 ````
	 LFFilterGifView *gifView = [[LFFilterGifView alloc] initWithFrame:self.bounds];
	gifView.contentMode = UIViewContentModeScaleAspectFit;
	// 使用UIImage初始化image.images.count > 0
	[gifView setImageByUIImage:image];
	// 使用NSData初始化
	// gifView.gifData = data;
	// 滤镜
	gifView.filter = [LFFilter filterWithCIFilterName:@"CIPhotoEffectChrome"];
	[self addSubview: gifView];
	 ````
 
3. 混合滤镜
	
	````
	LFFilter *filter1 = [LFFilter filterWithCIFilterName:@"CIPhotoEffectChrome"];
	LFFilter *filter2 = [LFFilter filterWithCIFilterName:@"CIPhotoEffectMono"];
	LFMutableFilter *filter = [LFMutableFilter emptyFilter];
	[filter addSubFilter:filter1];
	[filter addSubFilter:filter2];
	view.filter = filter;
	````
	
4. 自定义滤镜
	
	````
	CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
	[filter setValue:@0.8 forKey:@"inputIntensity"];
	LFFilter *filter = [LFFilter filterWithCIFilter:filter];
	view.filter = filter;
	````
	
	````
	LFFilter *filter = [LFFilter filterWithBlock:^CIImage * _Nullable(CIImage * _Nonnull image) {
        // do something ...
        return CIImage;
    }];
	view.filter = filter;
	````
	
5. 导出视频

	````
	// 使用视频AVAsset初始化
	self.exportSession = [[LFVideoExportSession alloc] initWithAsset:asset];
	// 输出路径
	self.exportSession.outputURL = trimURL;
	// 视频剪辑
	self.exportSession.timeRange = range;
	// 水印
	self.exportSession.overlayView = overlayView;
	// 滤镜
	self.exportSession.filter = filter;
	// 自定义音乐路径
	self.exportSession.audioUrls = audioUrls
	[self.exportSession exportAsynchronouslyWithCompletionHandler:^(NSError *error) {
	    NSLog(@"视频路径:%@ error:%@", trimURL, error);
	} progress:^(float progress) {
	    NSLog(@"进度:%f", progress);
	}];
	````
	
## 注意事项
* 请使用真机调试，模拟器测试GPU可能会出现卡顿的情况。
* 如果视频播放（LFFilterVideoView）的filter属性与视频导出（LFVideoExportSession）的filter属性是**同一个对象地址(LFVideoExportSession.filter = LFFilterVideoView.filter)**。导出之前请将视频**暂停播放[AVPlayer pause]**，否则播放视频与导出视频都有可能出现**画面闪烁**的情况。
