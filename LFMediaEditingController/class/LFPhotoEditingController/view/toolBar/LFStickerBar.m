//
//  LFStickerBar.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/21.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFStickerBar.h"
#import "LFMediaEditingHeader.h"
#import "UIView+LFMEFrame.h"

#define lf_stickerRow 2
#define lf_stickerSize 60
#define lf_pageControlHeight 30

@interface LFStickerBar () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray<NSString *> *files;

@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, weak) UIScrollView *lf_scrollViewSticker;
@property (nonatomic, weak) UIPageControl *lf_pageControlSticker;

@end

@implementation LFStickerBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    if (iOS8Later) {
        // 定义毛玻璃效果
        self.backgroundColor = [UIColor clearColor];
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
        effe.frame = self.bounds;
        [self addSubview:effe];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    }
    self.userInteractionEnabled = YES;
    /** 添加按钮获取点击 */
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton.frame = self.bounds;
    [self addSubview:bgButton];
    
    NSFileManager *fileManager = [NSFileManager new];
    NSString *path = [[NSBundle mainBundle] pathForResource:kStickersPath ofType:nil];
    self.files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSInteger count = self.files.count;
    [self setupScrollView:count];
    [self setupPageControl];
}

- (void)setupScrollView:(NSInteger)count
{
    
    UIScrollView *lf_scrollViewSticker = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [lf_scrollViewSticker setBackgroundColor:[UIColor clearColor]];
    NSInteger index = 0;
    
    NSInteger row = lf_stickerRow;
    NSInteger column = self.frame.size.width / (lf_stickerSize + self.frame.size.width * 0.1);
    
    CGFloat size = lf_stickerSize;
    CGFloat marginRow = (lf_scrollViewSticker.bounds.size.width-column*size)/(column+1);
    CGFloat marginColumn = (lf_scrollViewSticker.bounds.size.height-row*size)/(row+1);
    
    NSInteger pageCount = count/(row*column);
    pageCount = count%(row*column) > 0 ? pageCount + 1 : pageCount;
    self.pageCount = pageCount;
    
    for (NSInteger pageIndex = 0; pageIndex < pageCount; pageIndex ++) {
        
        CGFloat x = pageIndex * self.bounds.size.width;
        
        for (NSInteger j=1; j<=row; j++) {
            for (NSInteger i=1;i<=column;i++) {
                if (index >= count) break;
                UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setFrame:CGRectMake((x + i * marginRow + (i - 1) * size), (j * marginColumn + (j - 1) * size), size, size)];
                [button setBackgroundColor:[UIColor clearColor]];
                UIImage * backImage = bundleStickerImageNamed(self.files[index]);
                [button setBackgroundImage:backImage forState:UIControlStateNormal];
                button.tag = index;
                [button addTarget:self action:@selector(stickerClicked:) forControlEvents:UIControlEventTouchUpInside];
                index++;
                [lf_scrollViewSticker addSubview:button];
            }
        }
    }
    
    [lf_scrollViewSticker setShowsVerticalScrollIndicator:NO];
    [lf_scrollViewSticker setShowsHorizontalScrollIndicator:NO];
    lf_scrollViewSticker.alwaysBounceHorizontal = YES;
    lf_scrollViewSticker.contentSize=CGSizeMake(self.bounds.size.width * pageCount, 0);
    lf_scrollViewSticker.pagingEnabled=YES;
    lf_scrollViewSticker.delegate=self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testPressed)];
    [lf_scrollViewSticker addGestureRecognizer:tap];
    [self addSubview:lf_scrollViewSticker];
    self.lf_scrollViewSticker = lf_scrollViewSticker;
}

- (void)testPressed
{
    /** 接收scrollView的点击事件，避免传递到下层控件响应 */
}

- (void)setupPageControl
{
    if (self.pageCount > 1) {
        CGFloat width = 150.0;
        CGFloat x = self.bounds.size.width/2 - width/2;
        UIPageControl *lf_pageControlSticker=[[UIPageControl alloc]initWithFrame:CGRectMake( x,self.height-lf_pageControlHeight,width,lf_pageControlHeight)];
        [lf_pageControlSticker setCurrentPage:0];
        lf_pageControlSticker.numberOfPages = self.pageCount;   //指定页面个数
        [lf_pageControlSticker setBackgroundColor:[UIColor clearColor]];
        [lf_pageControlSticker setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        [lf_pageControlSticker setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [lf_pageControlSticker addTarget:self action:@selector(stickerPageControl:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:lf_pageControlSticker];
        self.lf_pageControlSticker = lf_pageControlSticker;
    }
}

- (void)stickerClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(lf_stickerBar:didSelectImage:)]) {
        [self.delegate lf_stickerBar:self didSelectImage:[button backgroundImageForState:UIControlStateNormal]];
    }
}

#pragma mark - pageControl滚动事件
- (void)stickerPageControl:(UIPageControl *)pageControl
{
    NSInteger page = pageControl.currentPage;//获取当前pagecontroll的值
    [self.lf_scrollViewSticker setContentOffset:CGPointMake(self.bounds.size.width * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 设置pageCotrol 当前对应位置
    NSInteger currentPage = self.lf_scrollViewSticker.contentOffset.x / self.bounds.size.width;
    [self.lf_pageControlSticker setCurrentPage:currentPage];
}

@end
