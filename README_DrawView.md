# 关于绘画功能

* LFDrawView已经是一个独立项目。 `pod 'LFMediaEditingController/LFDrawView'`
* 它集成了一些画笔：
	1. LFPaintBrush 普通画笔
	2. LFHighlightBrush 双色笔
	3. LFFluorescentBrush 荧光笔
	4. LFChalkBrush 粉笔
	5. LFStampBrush 图章
	6. LFMosaicBrush 马赛克（仅支持图片）
	7. LFBlurryBrush 高斯模糊（仅支持图片）
	8. LFSmearBrush 涂抹（仅支持图片）
	9. LFEraserBrush 橡皮擦（仅支持图片）
* 它的开发框架很简单，只要你脑洞够大，可以实现很多有趣的画笔。因为它是基于CGLayer的开发，所以对于某些画笔的实现表示无奈。例如：毛笔。
* 以上标注“仅支持图片”的画笔与滤镜的兼容性不好，特别是橡皮擦。因为它们是依赖图片来实现的，当图片发生了变化，必须将相关的全部图层都修改一次。
* 它与LFFilterSuite框架的兼容性更加糟糕，LFFilterSuite框架是使用CIImage来展示，切换滤镜后无法与画笔图层同步修改。
* 橡皮擦功能暂时不会开放在LFMediaEditingController，除非有更好的实现方式。如果不使用滤镜的话，橡皮擦是一个不错的画笔。

# 橡皮擦效果DEMO
* [DrawEraserDemo](https://github.com/lincf0912/LFMediaEditingController/blob/master/Demo/DrawEraserDemo.zip)

# 橡皮擦效果展示
![image](https://github.com/lincf0912/LFMediaEditingController/blob/master/ScreenShots/screenshot_eraser.gif)
