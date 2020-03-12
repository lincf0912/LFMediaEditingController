//
//  JRImageCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRImageCollectionViewCell.h"
#import "UIView+LFDownloadManager.h"
#import "LFStickerProgressView.h"
#import "JRStickerContent.h"
#import "JRPHAssetManager.h"
#import "JRConfigTool.h"
#import "JRDataImageView.h"
#import "JRStickerHeader.h"
#import "NSData+JRImageContentType.h"

CGFloat const JR_kVideoBoomHeight = 25.f;
@interface JRImageCollectionViewCell ()

@property (weak, nonatomic) JRDataImageView *imageView;

@property (weak, nonatomic) LFStickerProgressView *progressView;

@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) UILabel *bottomLab;

@property (strong, nonatomic) CAShapeLayer *maskLayer;

@end

@implementation JRImageCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.progressView.center = self.contentView.center;
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - JR_kVideoBoomHeight, CGRectGetWidth(self.contentView.bounds), JR_kVideoBoomHeight);
    self.bottomLab.frame = CGRectInset(self.bottomView.bounds, 2.5f, 5.f);
    CGFloat markMargin = [JRConfigTool shareInstance].itemMargin/2;
    CGRect markRect = CGRectInset(self.contentView.bounds, -markMargin, -markMargin);
    self.maskLayer.frame = markRect;
    self.maskLayer.cornerRadius = CGRectGetWidth(markRect) * 0.05;

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (void)dealloc
{
    [self lf_downloadCancel];
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    self.bottomView.hidden = YES;
    __block JRStickerContent *obj = (JRStickerContent *)data;
    if (obj.state == JRStickerContentState_Fail) {
        self.imageView.image = [JRConfigTool shareInstance].failureImage;
        return;
    }
    id itemData = obj.content;
    if (obj.type == JRStickerContentType_URLForFile) {
        NSURL *fileURL = (NSURL *)itemData;
        NSData *localData = [NSData dataWithContentsOfURL:fileURL];
        if ([NSData jr_imageFormatForImageData:localData] == JRImageFormatUndefined) {
            obj.state = JRStickerContentState_Fail;
            self.imageView.image = [JRConfigTool shareInstance].failureImage;
        } else {
            obj.state = JRStickerContentState_Success;
#ifdef jr_NotSupperGif
            self.bottomView.hidden = YES;
#else
            self.bottomView.hidden =  !self.imageView.isGif;
#endif
            [self.imageView jr_dataForImage:localData];
        }
    } else if (obj.type == JRStickerContentType_URLForHttp) {
        NSURL *httpURL = (NSURL *)itemData;
        NSData *httplocalData = [self dataFromCacheWithURL:httpURL];
        if (httplocalData) {
            if ([NSData jr_imageFormatForImageData:httplocalData] == JRImageFormatUndefined) {
                obj.state = JRStickerContentState_Fail;
                self.imageView.image = [JRConfigTool shareInstance].failureImage;
            } else {
                obj.state = JRStickerContentState_Success;
                [self.imageView jr_dataForImage:httplocalData];
#ifdef jr_NotSupperGif
                self.bottomView.hidden = YES;
#else
                self.bottomView.hidden =  !self.imageView.isGif;
#endif
            }
        } else {
            [self _download:obj];
        }
    } else if (obj.type == JRStickerContentType_PHAsset) {
        self.imageView.image = [JRConfigTool shareInstance].normalImage;
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
#ifdef jr_NotSupperGif
        self.bottomView.hidden = YES;
#else
        self.bottomView.hidden = ![JRPHAssetManager jr_IsGif:itemData];
#endif
        __weak typeof(self) weakSelf = self;
        [JRPHAssetManager jr_GetPhotoWithAsset:itemData photoWidth:self.frame.size.width completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
            weakSelf.progressView.hidden = YES;
            if (!result) {
                obj.state = JRStickerContentState_Fail;
                weakSelf.imageView.image = [JRConfigTool shareInstance].failureImage;
            } else {
                obj.state = JRStickerContentState_Success;
                weakSelf.imageView.image = result;
            }
        } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            weakSelf.progressView.progress = progress;
        }];
    }
}


- (void)showMaskLayer:(BOOL)isShow
{
    self.maskLayer.hidden = !isShow;
}

- (void)resetForDownloadFail
{
    JRStickerContent *content = (JRStickerContent *)self.cellData;
    if (content.state == JRStickerContentState_Fail) {
        content.state = JRStickerContentState_Downloading;
        [self _download:content];
    }
}
#pragma mark - Private Methods
- (void)_initSubViewAndDataSources
{
    self.contentView.backgroundColor = [UIColor clearColor];

    JRDataImageView *imageView = [[JRDataImageView alloc] initWithFrame:self.contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.image = [JRConfigTool shareInstance].normalImage;

    LFStickerProgressView *view1 = [[LFStickerProgressView alloc] init];
    [self.contentView addSubview:view1];
    [self.contentView bringSubviewToFront:view1];
    self.progressView = view1;
    
    /** 底部状态栏 */
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, self.contentView.frame.size.height - JR_kVideoBoomHeight, self.contentView.frame.size.width, JR_kVideoBoomHeight);
    [self.contentView addSubview:bottomView];
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bottomView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0f alpha:.0f] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor], nil];
    [bottomView.layer insertSublayer:gradientLayer atIndex:0];
    self.bottomView = bottomView;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectInset(bottomView.bounds, 2.5f, 5.f)];
    lab.textAlignment = NSTextAlignmentRight;
    lab.text = @"GIF";
    lab.textColor = [UIColor whiteColor];
    [self.bottomView addSubview:lab];
    self.bottomLab = lab;
    
    CGFloat markMargin = [JRConfigTool shareInstance].itemMargin/2;
    CGRect markRect = CGRectInset(self.contentView.bounds, -markMargin, -markMargin);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.bounds = markRect;
    maskLayer.hidden = YES;
    maskLayer.cornerRadius = CGRectGetWidth(markRect) * 0.05;
    maskLayer.backgroundColor = [UIColor colorWithWhite:.5f alpha:.7f].CGColor;
    [self.contentView.layer insertSublayer:maskLayer below:self.imageView.layer];
    self.maskLayer = maskLayer;
}

- (void)_download:(JRStickerContent *)content
{
    if (content.type != JRStickerContentType_URLForHttp) {
        return;
    }
        
    content.state = JRStickerContentState_Downloading;
    
    self.imageView.image = [JRConfigTool shareInstance].normalImage;
    NSURL *httpURL = (NSURL *)content.content;
    self.progressView.hidden = NO;
    self.progressView.progress = content.progress;
    __weak typeof(self) weakSelf = self;
    [self lf_downloadImageWithURL:httpURL progress:^(CGFloat progress, NSURL * _Nonnull URL) {
        if ([URL.absoluteString isEqualToString:httpURL.absoluteString]) {
            weakSelf.progressView.progress = content.progress = progress;
        }
    } completed:^(NSData * _Nonnull downloadData, NSError * _Nonnull error, NSURL * _Nonnull URL) {
        if ([URL.absoluteString isEqualToString:httpURL.absoluteString]) {
            weakSelf.progressView.hidden = YES;
            if (error || downloadData == nil) {
                content.state = JRStickerContentState_Fail;
                weakSelf.imageView.image = [JRConfigTool shareInstance].failureImage;
            } else {
                if ([NSData jr_imageFormatForImageData:downloadData] == JRImageFormatUndefined) {
                    content.state = JRStickerContentState_Fail;
                    weakSelf.imageView.image = [JRConfigTool shareInstance].failureImage;
                } else {
                    
                    content.state = JRStickerContentState_Success;
                    [weakSelf.imageView jr_dataForImage:downloadData];
#ifdef jr_NotSupperGif
                    weakSelf.bottomView.hidden = YES;
#else
                    weakSelf.bottomView.hidden =  !weakSelf.imageView.isGif;
#endif
                }
            }
        }
        
    }];

}
@end
