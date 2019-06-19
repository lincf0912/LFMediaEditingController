# LFFilterSuite

* 代码来源于[SCRecorder](https://github.com/rFlex/SCRecorder)项目，向该项目的开发人员致敬并感谢。  
* 本套件降低了使用的复杂性。
* 重命名类名，避免冲突。
* 新增对超大图片的支持。
* 新增可以使用UIKit

## 大图片的使用
LFContextTypeAuto 在预览大图的时候展示图片会模糊不清，特别是长图片。以GLKView为例。
1、哪些图片会模糊不清？
> 缩放屏幕比例后的尺寸太小的图片，例如：原图片尺寸为：288 × 7960，缩放屏幕比例后的尺寸为（ipx为例）：29x812。因为展示的实际像素只有29x812，被UIScrollView放大后。但展示的视图仍然是使用29x812像素来绘制288 × 7960的图片，屏幕所展示的是放大后的部分像素，所以会模糊不清。实际上在没有放大的情况下就已经模糊不清了，理论上GLKView的大小需要与图片的大小一致，它们才能保存原有的清晰度。而设置GLKView的大小超过一定的范围（根据不同的机型而定）时，GLKView的开销会超出预算导致无法运作。

2、怎样可以还原大图片的清晰度？
> ·可以将contextType设置为LFContextTypeLargeImage，它是专门预览大图的。它对大图片的内存使用也是极佳的。但是小图片建议不要使用。
> ·可以将contextType设置为LFContextTypeEAGL，并且将LFContextImageView.contentView指向UIScrollView的superView。在UIScrollView的代理方法中`- (void)scrollViewDidScroll:(UIScrollView *)scrollView` 与 `- (void)scrollViewDidZoom:(UIScrollView *)scrollView` 加入`[self.LFContextImageView setNeedsDisplay];`。 它的工作原理是使用contentView的像素实时绘制图片的可视范围像素来达到原图的清晰图。简单点说就是GLKView的大小是屏幕大小，绘制时对图片剪裁，仅绘制图片在屏幕的可见范围，达到GLKView的大小与图片的大小一致。但它是有缺陷的。总的来说OpenGLES，或者即将取代它的Metal，它们都与UIScrollView兼容性很差。
> >缺陷1：如果UIScrollView旋转了视图，那么LFContextImageView也要跟随旋转，注意，仅是旋转部分的transform。
> >缺陷2：当UIScrollView缩小超出最小范围后，回弹动画不跟随。放大同样。



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
