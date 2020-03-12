//
//  JRCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/19.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRCollectionViewCell.h"
#import "JRImageCollectionViewCell.h"
#import "LFEditCollectionView.h"
#import "JRStickerContent.h"
#import "JRConfigTool.h"
#import "JRStickerHeader.h"
#import "JRStickerContent+JRGetData.h"
#import "JRPHAssetManager.h"

#import "NSObject+LFTipsGuideView.h"
#import "NSBundle+LFMediaEditing.h"

@interface JRCollectionViewCell () <LFEditCollectionViewDelegate>

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@property (strong, nonatomic) NSIndexPath *longPressIndexPath;

@end

@implementation JRCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _initSubView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.collectionView.dataSources = @[];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [self.collectionView removeFromSuperview];
    [self _removeDisplayView];
}

#pragma mark - Public Methods
- (void)setCellData:(id)data index:(NSInteger)index
{
    [super setCellData:data];
    self.collectionView.dataSources = @[];
    if ([data isKindOfClass:[NSArray class]]) {
        self.collectionView.dataSources = @[data];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView reloadData];
    } completion:^(BOOL finished) {
        if (index == 0) {
            UICollectionViewCell *cell = [weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (cell) {
                [self lf_showInView:[UIApplication sharedApplication].keyWindow maskRects:@[[NSValue valueWithCGRect:[cell.superview convertRect:cell.frame toView:nil]]] withTips:@[[NSBundle LFME_localizedStringForKey:@"_LFME_UserGuide_StickerView_DisplayView_LongPress"]]];
            }
        }
    }];
}

- (void)setCellData:(id)data
{
    [self setCellData:data index:NSNotFound];
}

#pragma mark - Private Methods
- (void)_initSubView
{
    __weak typeof(self) weakSelf = self;
    LFEditCollectionView *col = [[LFEditCollectionView alloc] initWithFrame:self.contentView.bounds];
    col.itemSize = [JRConfigTool shareInstance].itemSize;
    col.delegate = self;
    col.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:col];
    self.collectionView = col;
    [self.collectionView registerClass:[JRImageCollectionViewCell class] forCellWithReuseIdentifier:[JRImageCollectionViewCell identifier]];
    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRImageCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, JRStickerContent * _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)cell;
        [imageCell setCellData:item];
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, JRStickerContent * _Nonnull item) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        JRStickerContent *obj = (JRStickerContent *)imageCell.cellData;
        if (item.state == JRStickerContentState_Success) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectData:thumbnailImage:index:)]) {
                [obj jr_getImageAndData:^(NSData * _Nullable data, UIImage * _Nullable image) {
                    [weakSelf.delegate didSelectData:data thumbnailImage:image index:indexPath.row];
                }];
            }
        } else if (item.state == JRStickerContentState_Fail) {
            if (obj.type == JRStickerContentType_URLForHttp) {
                [imageCell resetForDownloadFail];
            }
        }
    }];
    
    UILongPressGestureRecognizer *ge = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longpress:)];
    self.backgroundColor = [UIColor blackColor];
    [self addGestureRecognizer:ge];

}

static LFMEGifView *_jr_showView = nil;
static UIView *_jr_contenView = nil;
static JRStickerContent *_showStickerContent = nil;

- (void)_removeDisplayView
{
    if (_jr_contenView) {
        [_jr_contenView removeFromSuperview];
        [_jr_showView removeFromSuperview];
        _jr_showView = nil;
        _jr_contenView = nil;
        _showStickerContent = nil;
    }
}

- (void)_showDisplayView:(JRImageCollectionViewCell *)cell
{
    if (!cell) {
        _jr_contenView.hidden = YES;
        return;
    }
    
    _showStickerContent = (JRStickerContent *)cell.cellData;
    if (_showStickerContent.state == JRStickerContentState_Fail) {
        _jr_contenView.hidden = YES;
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect covertRect = [cell.superview convertRect:cell.frame toView:keyWindow];
    /** 主容器和cell的间距 */
    CGFloat topMargin = [JRConfigTool shareInstance].itemMargin;
    /** 长按cell的选择模式大小 */
    covertRect = CGRectInset(covertRect, -topMargin/2, -topMargin/2);
    
    if (!_jr_contenView) {
        
        {
            UIView *contenView = [[UIView alloc] initWithFrame:CGRectZero];
            contenView.backgroundColor = [UIColor whiteColor];
            contenView.hidden = YES;
            [keyWindow addSubview:contenView];
            [keyWindow bringSubviewToFront:contenView];
            _jr_contenView = contenView;
        }
        
        {
            LFMEGifView *gifView = [[LFMEGifView alloc] initWithFrame:CGRectZero];
            [_jr_contenView addSubview:gifView];
            _jr_showView = gifView;
        }
        
    }
    
    /** 展示图片与主容器的间隔 */
    CGFloat margin = 8.f;
    
    CGRect contentViewF = _jr_contenView.frame;
    
    contentViewF.size = CGSizeMake(CGRectGetWidth(covertRect)*2, CGRectGetHeight(covertRect)*2);
    /** 图片实际大小 */
    CGSize imageSize = cell.image.size;
    /** 转换容器大小 */
    CGRect convertF = CGRectInset(contentViewF, margin, margin);
    /** 实际比例  */
    CGFloat radio = CGRectGetWidth(convertF)/imageSize.width;
    if (imageSize.width > imageSize.height) {
        radio = CGRectGetHeight(convertF)/imageSize.height;
    }
    /** 展示图片大小 */
    imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    if (imageSize.width > (CGRectGetWidth(keyWindow.bounds) - margin*2)) {
        radio = (CGRectGetWidth(keyWindow.bounds) - margin*2)/imageSize.width;
        imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    } else if (imageSize.height > (CGRectGetMinY(covertRect) - margin*2 - topMargin*2)) {
        radio = ((CGRectGetMinY(covertRect) - margin*2 - topMargin*2) - margin*2)/imageSize.height;
        imageSize = CGSizeMake(roundf(imageSize.width * radio), roundf(imageSize.height * radio));
    }
    
    /** 根据展示大小确定主容器大小 */
    contentViewF.size = CGSizeMake(imageSize.width + margin*2, imageSize.height + margin*2);
    contentViewF.origin = CGPointMake(CGRectGetMidX(covertRect) - CGRectGetWidth(contentViewF)/2, CGRectGetMinY(covertRect) - topMargin - CGRectGetHeight(contentViewF));

    /** 如果主容器x坐标超过当前屏幕 */
    if (CGRectGetMaxX(contentViewF) > CGRectGetWidth(keyWindow.bounds)) {
        CGFloat margin = CGRectGetMaxX(contentViewF) - CGRectGetWidth(keyWindow.bounds);
        contentViewF.origin.x -= margin;
    }
    
    /** 主容器y坐标超过当前屏幕 */
    if (CGRectGetMinY(contentViewF) < 0) {
        contentViewF.origin.y = topMargin + CGRectGetMaxY(covertRect);
        if (CGRectGetMaxY(contentViewF) > CGRectGetHeight(keyWindow.bounds)) {
            contentViewF.origin.y = CGRectGetMinY(covertRect) - topMargin - CGRectGetHeight(contentViewF);
        }
    }
    
    if (CGRectGetMinX(contentViewF) < 0) {
        contentViewF.origin.x = 0.f;
    }

    
    _jr_contenView.frame = contentViewF;
    _jr_contenView.layer.cornerRadius = MIN(CGRectGetWidth(contentViewF), CGRectGetHeight(contentViewF)) * 0.05;
    
    _jr_showView.frame = CGRectMake(margin, margin, imageSize.width, imageSize.height);
    
    
#ifdef jr_NotSupperGif
    [_showStickerContent jr_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
        if (_showStickerContent == cell.cellData) {
            _jr_showView.image = image;
            _jr_contenView.hidden = NO;
        }
    }];
    
#else
    if (_showStickerContent.type == JRStickerContentType_PHAsset) {
        if ([JRPHAssetManager jr_IsGif:_showStickerContent.content]) {
            [_showStickerContent jr_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
                if (_showStickerContent == cell.cellData) {
                    _jr_showView.image = image;
                    _jr_contenView.hidden = NO;
                }
            }];
        } else {
            [_showStickerContent jr_getData:^(NSData * _Nullable data) {
                if (_showStickerContent == cell.cellData) {
                    _jr_showView.data = data;
                    _jr_contenView.hidden = NO;
                }
            }];
        }
    } else {
        [_showStickerContent jr_getData:^(NSData * _Nullable data) {
            if (_showStickerContent == cell.cellData) {
                _jr_showView.data = data;
                _jr_contenView.hidden = NO;
            }
        }];
    }
#endif
}

- (void)_longpress:(UILongPressGestureRecognizer *)longpress
{
    CGPoint location = [longpress locationInView:self];
    location = [self convertPoint:location toView:self.collectionView];
    location.x += self.collectionView.contentOffset.x;
    location.y += self.collectionView.contentOffset.y;
    
    switch (longpress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.longPressIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
            [cell showMaskLayer:YES];
            [self _showDisplayView:cell];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势位置改变
            NSIndexPath *changeIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            if ((changeIndexPath && changeIndexPath.row != self.longPressIndexPath.row) || !self.longPressIndexPath) {
                NSIndexPath *oldIndexPath = self.longPressIndexPath;
                JRImageCollectionViewCell *oldCell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:oldIndexPath];
                [oldCell showMaskLayer:NO];
                self.longPressIndexPath = changeIndexPath;
                JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                [cell showMaskLayer:YES];
                [self _showDisplayView:cell];
            } else if (changeIndexPath == nil) {
                [self _removeDisplayView];
                if (self.longPressIndexPath) {
                    JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                    [cell showMaskLayer:NO];
                    self.longPressIndexPath = nil;
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        {
            [self _removeDisplayView];
            if (self.longPressIndexPath) {
                JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                [cell showMaskLayer:NO];
                self.longPressIndexPath = nil;
            }
        }
            break;
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return margin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemSize.width * count) / (count + 1);
    return margin;
}

@end
