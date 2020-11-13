//
//  LFStickerItem.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/20.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFStickerItem.h"
#import "NSAttributedString+LFMECoreText.h"
#import "LFCGContextDrawTextBackground.h"

@interface LFStickerItem ()

@property (nonatomic, assign) UIEdgeInsets textInsets; // 控制字体与控件边界的间隙
@property (nonatomic, strong) UIImage *textCacheDisplayImage;

@property (nonatomic, strong) AVAssetImageGenerator *generator;

@end

@implementation LFStickerItem

+ (instancetype)mainWithImage:(UIImage *)image
{
    LFStickerItem *item = [[self alloc] initMain];
    item.image = image;
    return item;
}

+ (instancetype)mainWithVideo:(AVAsset *)asset
{
    LFStickerItem *item = [[self alloc] initMain];
    item.asset = asset;
    return item;
}

- (instancetype)initMain
{
    self = [self init];
    if (self) {
        _main = YES;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textInsets = UIEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    }
    return self;
}

- (void)setText:(LFText *)text
{
    _text = text;
    _textCacheDisplayImage = nil;
}

- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    _generator = nil;
}

- (UIImage * __nullable)displayImage
{
    if (self.image) {
        return self.image;
    } else if (/*self.text.text.length || */self.text.attributedText.length) {
        
        if (_textCacheDisplayImage == nil) {
            
            NSRange range = NSMakeRange(0, 1);
            CGSize textSize = [self.text.attributedText LFME_sizeWithConstrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-(self.textInsets.left+self.textInsets.right), CGFLOAT_MAX)];
            NSDictionary *typingAttributes = [self.text.attributedText attributesAtIndex:0 effectiveRange:&range];
            
            UIColor *textColor = [typingAttributes objectForKey:NSForegroundColorAttributeName];
            
            CGPoint point = CGPointMake(self.textInsets.left, self.textInsets.top);
            CGPoint origin = CGPointMake(self.textInsets.left, self.textInsets.top);
            
            CGSize size = textSize;
            if (!CGRectIsNull(self.text.usedRect)) {
                /** 因为高度的偏差不明，使用UITextView的文字高度效果更佳。 */
                textSize.height = self.text.usedRect.size.height;
                /** 改变画布大小 */
                point.x += (self.text.usedRect.size.width - textSize.width)/2;
                point.y += (self.text.usedRect.size.height - textSize.height)/2;
                size = self.text.usedRect.size;
            }
            CGSize usedSize = size;
            
            size.width += (self.textInsets.left+self.textInsets.right);
            size.height += (self.textInsets.top+self.textInsets.bottom);
            
            
            
            @autoreleasepool {
                /** 创建画布 */
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                if (self.text.layoutData) {
                    CGContextSaveGState(context);   //保存当前的绘图配置信息
                    CGContextTranslateCTM(context, origin.x, origin.y); //转换初始坐标系到绘制字形的位置
                    lf_CGContextDrawTextBackgroundData(context, usedSize, self.text.layoutData);
                    CGContextRestoreGState(context); //恢复绘图配置信息
                } else {
                    /** 没有背景色反差时，添加阴影 */
                    UIColor *shadowColor = ([textColor isEqual:[UIColor blackColor]]) ? [UIColor whiteColor] : [UIColor blackColor];
                    CGColorRef shadow = [shadowColor colorWithAlphaComponent:0.8f].CGColor;
                    CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 3.f, shadow);
                    CGContextSetAllowsAntialiasing(context, YES);
                }
                
                [self.text.attributedText LFME_drawInContext:context withPosition:point andHeight:textSize.height andWidth:textSize.width];
                
                UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                _textCacheDisplayImage = temp;
            }
            
        }
        
        return _textCacheDisplayImage;
    }
    return nil;
}

- (UIImage * __nullable)displayImageAtTime:(NSTimeInterval)time
{
    if (self.displayImage.images.count) {
        NSInteger frameCount = self.displayImage.images.count;
        NSTimeInterval duration = self.displayImage.duration / frameCount;
        NSInteger index = time / duration;
        index = index % frameCount;
        return [self.displayImage.images objectAtIndex:index];
    } else if (self.asset) {
        if (_generator == nil) {
            AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
            generator.appliesPreferredTrackTransform = YES;
            CMTime tol = CMTimeMakeWithSeconds([@(0.01) floatValue], self.asset.duration.timescale);
            generator.requestedTimeToleranceBefore = tol;
            generator.requestedTimeToleranceAfter = tol;
            _generator = generator;
        }
        CMTime index = CMTimeMakeWithSeconds(time, self.asset.duration.timescale);
        NSError *error;
        CGImageRef imageRef = [_generator copyCGImageAtTime:index actualTime:nil error:&error];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return image;
        
    }
    return self.displayImage;
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _main = [coder decodeBoolForKey:@"main"];
        _image = [coder decodeObjectForKey:@"image"];
        NSURL *assetURL = [coder decodeObjectForKey:@"assetURL"];
        if (assetURL) {
            _asset = [AVAsset assetWithURL:assetURL];            
        }
        _textCacheDisplayImage = [coder decodeObjectForKey:@"textCacheDisplayImage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isMain forKey:@"main"];
    [coder encodeObject:self.image forKey:@"image"];
    if ([_asset isKindOfClass:[AVURLAsset class]]) {
        NSURL *assetURL = ((AVURLAsset *)_asset).URL;
        [coder encodeObject:assetURL forKey:@"assetURL"];
    }
    [coder encodeObject:_textCacheDisplayImage forKey:@"textCacheDisplayImage"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
