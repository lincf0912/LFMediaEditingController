//
//  JRTitleShowView.m
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRStickerDisplayView.h"
#import "JRCollectionViewCell.h"
#import "JRTitleCollectionViewCell.h"
#import "JRStickerContent.h"
#import "JRConfigTool.h"
#import "JRStickerHeader.h"
#import "JRCollectionViewTitleModel.h"

NSString * const jr_local_title_key = @"jr_local_title_key";
NSString * const jr_local_content_key = @"jr_local_content_key";

#define JRStickerDisplayView_bind_var(varType, varName, setterName) \
JRSticker_bind_var_getter(varType, varName, [JRConfigTool shareInstance]) \
JRSticker_bind_var_setter(varType, varName, setterName, [JRConfigTool shareInstance])

/** 按钮在scrollView的间距 */
CGFloat const JR_O_margin = 15.f;

@interface JRStickerDisplayView () <JRCollectionViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (readonly , nonatomic, nonnull) NSArray <JRCollectionViewTitleModel *>*titles;

@property (readonly , nonatomic, nonnull) NSArray <NSArray <JRStickerContent *>*>*contents;

@property (strong, nonatomic) JRCollectionViewTitleModel *selectTitleMoel;

@property (assign, nonatomic) BOOL stopAnimation;

@property (strong, nonatomic, nullable) NSIndexPath *selectIndexPath;

@property (weak, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) UICollectionView *titleCollectionView;

@property (weak, nonatomic) UIView *lineView;

@end

@implementation JRStickerDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stopAnimation = YES;
        self.backgroundColor = [UIColor blackColor];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _customLayoutSubviews];
}

- (void)dealloc
{
    [self.titleCollectionView removeFromSuperview];
    [self.collectionView removeFromSuperview];
    self.titleCollectionView = nil;
    self.collectionView = nil;
}
    
JRStickerDisplayView_bind_var(UIColor *, selectTitleColor, setSelectTitleColor);
JRStickerDisplayView_bind_var(UIColor *, normalTitleColor, setNormalTitleColor);
JRStickerDisplayView_bind_var(CGSize, itemSize, setItemSize);
JRStickerDisplayView_bind_var(CGFloat, itemMargin, setItemMargin);
JRStickerDisplayView_bind_var(UIImage *, normalImage, setNormalImage);
JRStickerDisplayView_bind_var(UIImage *, failureImage, setFailureImage);

#pragma mark - @Public Methods
- (void)setTitles:(NSArray *)titles contents:(NSArray<NSArray *> *)contents
{
    NSMutableArray *titleModels = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSString *string in titles) {
        JRCollectionViewTitleModel *model = [[JRCollectionViewTitleModel alloc] initWithTitle:string];
        [titleModels addObject:model];
    }
    _titles = [titleModels copy];
    _selectTitleMoel = [_titles firstObject];
    NSMutableArray *r_contents = [NSMutableArray arrayWithCapacity:contents.count];
    for (NSArray *subContents in contents) {
        NSMutableArray *s_contents = [NSMutableArray arrayWithCapacity:subContents.count];
        for (id content in subContents) {
            [s_contents addObject:[JRStickerContent stickerContentWithContent:content]];
        }
        [r_contents addObject:[s_contents copy]];
    }
    _contents = [r_contents copy];
    if (_titles.count) {
        [self _initSubViews];
    }
    
}

- (void)setCacheData:(id)cacheData
{
    if ([cacheData isKindOfClass:[NSDictionary class]]) {
        NSArray *titles = @[];
        if ([[cacheData allKeys] containsObject:jr_local_title_key]) {
            titles = [cacheData objectForKey:jr_local_title_key];
        }
        
        NSMutableArray *titleModels = [NSMutableArray arrayWithCapacity:titles.count];
        for (NSDictionary *dic in titles) {
            [titleModels addObject:[[JRCollectionViewTitleModel alloc] initWithDictionary:dic]];
        }
        _titles = [titleModels copy];
        _selectTitleMoel = [_titles firstObject];

        NSArray *contents = @[];
        if ([[cacheData allKeys] containsObject:jr_local_content_key]) {
            contents = [cacheData objectForKey:jr_local_content_key];
        }
        
        
        NSMutableArray *r_contents = [NSMutableArray arrayWithCapacity:contents.count];

        for (NSArray *subContents in contents) {
            NSMutableArray *s_contents = [NSMutableArray arrayWithCapacity:subContents.count];
            for (NSDictionary *dic in subContents) {
                [s_contents addObject:[[JRStickerContent alloc] initWithDictionary:dic]];
            }
            [r_contents addObject:[s_contents copy]];
        }
        
        _contents = [r_contents copy];
        if (_titles.count) {
            [self _initSubViews];
        }

    }
}

- (id)cacheData
{
    NSArray *cacheContents = nil;
    if (!_contents ) {
        cacheContents = @[];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_contents.count];
        for (NSArray *subContents in _contents) {
            NSMutableArray *subArray = [NSMutableArray arrayWithCapacity:subContents.count];
            for (JRStickerContent *obj in subContents) {
                [subArray addObject:obj.dictionary];
            }
            [array addObject:[subArray copy]];
        }
        cacheContents = [array copy];
    }
    
    NSArray *cacheTitles = nil;
    if (!_titles) {
        cacheTitles = @[];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_titles.count];
        for (JRCollectionViewTitleModel *model in _titles) {
            [array addObject:model.dictionary];
        }
        cacheTitles = [array copy];
    }
    return @{jr_local_title_key:cacheTitles, jr_local_content_key:cacheContents};
}

#pragma mark - @Private Methods

#pragma mark 初始化视图
- (void)_initSubViews
{
    
    //title View
    {
        UICollectionViewFlowLayout *tFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        tFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        tFlowLayout.minimumLineSpacing = JR_O_margin;
        tFlowLayout.minimumInteritemSpacing = JR_O_margin;
        tFlowLayout.sectionInset = UIEdgeInsetsMake(JR_O_margin, JR_O_margin, JR_O_margin, JR_O_margin);
        
        JRCollectionViewTitleModel *model = [self.titles firstObject];
        CGFloat height = model.size.height + JR_O_margin*2;
        UICollectionView *titleView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), height) collectionViewLayout:tFlowLayout];
        titleView.showsVerticalScrollIndicator = NO;
        titleView.showsHorizontalScrollIndicator = NO;
        titleView.backgroundColor = [UIColor clearColor];
        titleView.delegate = self;
        titleView.dataSource = self;
        [self addSubview:titleView];
        self.titleCollectionView = titleView;
        
        [self.titleCollectionView registerClass:[JRTitleCollectionViewCell class] forCellWithReuseIdentifier:[JRTitleCollectionViewCell identifier]];

    }
    
    {
        UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.titleCollectionView.bounds), .3f)];
        marginView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8f];
        [self addSubview:marginView];
        self.lineView = marginView;
    }
    
    //九宫格
    {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 10.0, *)) {
            collectionView.prefetchingEnabled = NO;
        }
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        [self.collectionView registerClass:[JRCollectionViewCell class] forCellWithReuseIdentifier:[JRCollectionViewCell identifier]];
    }

}

#pragma mark 点击切换文字
- (void)_changeTitle:(JRCollectionViewTitleModel *)model
{
    if ([self.selectTitleMoel isEqual:model]) {
        return;
    }
    self.stopAnimation = YES;
    NSUInteger oldIndex = [self.titles indexOfObject:self.selectTitleMoel];
    NSUInteger selectIndex = [self.titles indexOfObject:model];
    self.selectTitleMoel = model;
    [self.titleCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:selectIndex inSection:0]]];
}

#pragma mark 切换文字动画效果
- (void)_changeTitleAnimotionProgress:(CGFloat)progress
{
    NSUInteger _selectedIndex = [self.titles indexOfObject:self.selectTitleMoel];
    //获取下一个index
    NSInteger targetIndex = progress < 0 ? _selectedIndex - 1 : _selectedIndex + 1;
    if (targetIndex < 0 || targetIndex >= [self.titles count]) return;

    //获取cell
    JRTitleCollectionViewCell *currentCell = (JRTitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    JRTitleCollectionViewCell *targetCell = (JRTitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
    
    [currentCell showAnimationOfProgress:progress select:NO];
    
    [targetCell showAnimationOfProgress:progress select:YES];

}

#pragma mark 适配横竖屏
- (void)_customLayoutSubviews
{
    self.stopAnimation = YES;
    
    NSInteger currentIndex = [self.titles indexOfObject:self.selectTitleMoel];

    CGRect topViewR = self.titleCollectionView.frame;

    topViewR.size.width = CGRectGetWidth(self.frame);
    self.titleCollectionView.frame = topViewR;
    [self.titleCollectionView.collectionViewLayout invalidateLayout];
    
    CGRect lineViewF = self.lineView.frame;
    lineViewF.origin.y = CGRectGetMaxY(self.titleCollectionView.frame);
    lineViewF.size.width = CGRectGetWidth(self.titleCollectionView.frame);
    self.lineView.frame = lineViewF;
    
    CGRect collectionViewR = self.collectionView.frame;
    if (CGRectEqualToRect(collectionViewR, CGRectZero)) {
        collectionViewR = CGRectMake(0.f, CGRectGetMaxY(lineViewF), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(lineViewF));
    }
    
    collectionViewR.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(lineViewF));
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = collectionViewR.size;
    self.collectionView.frame = collectionViewR;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.contentSize = CGSizeMake(self.titles.count * (self.collectionView.frame.size.width), 0.f);
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.titles.count) {
        [self.collectionView setContentOffset:CGPointMake((self.collectionView.frame.size.width) * currentIndex, 0) animated:NO];
    }
}


#pragma mark - @JRCollectionViewDelegate
- (void)didSelectData:(nullable NSData *)data thumbnailImage:(nullable UIImage *)thumbnailImage index:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self.titles indexOfObject:self.selectTitleMoel]];
    _selectIndexPath = indexPath;
    if (self.didSelectBlock) {
        self.didSelectBlock(data, thumbnailImage);
    }
    _selectIndexPath = nil;
}

#pragma mark - @UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        if (self.stopAnimation) {
            return;
        }
        NSInteger currentIndex = [self.titles indexOfObject:self.selectTitleMoel];
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        CGFloat value = scrollView.contentOffset.x/scrollView.bounds.size.width - [self.titles indexOfObject:self.selectTitleMoel];
        [self _changeTitleAnimotionProgress:value];
        CGFloat index = scrollView.contentOffset.x/scrollView.bounds.size.width;
        if (isnan(index)) {
            index = 0.f;
        }
        self.selectTitleMoel = [self.titles objectAtIndex:index];
        UICollectionViewCell *cell = [self.titleCollectionView cellForItemAtIndexPath:currentIndexPath];
        CGRect convertF = [self.titleCollectionView convertRect:cell.frame toView:self];
        if (!CGRectContainsRect(convertF, self.titleCollectionView.frame)) {
            [self.titleCollectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

//更新执行动画状态
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

////更新执行动画状态
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}


#pragma mark - @UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *resultCell = nil;
    NSString *identifier = nil;
    if (self.collectionView == collectionView) {
        identifier = [JRCollectionViewCell identifier];
        JRCollectionViewCell *imageCell = (JRCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        imageCell.delegate = self;
        imageCell.backgroundColor = [UIColor clearColor];
        if (self.contents.count > indexPath.row) {
            [imageCell setCellData:[self.contents objectAtIndex:indexPath.row]];
        } else {
            [imageCell setCellData:nil];
        }
        resultCell = imageCell;
    } else if (self.titleCollectionView == collectionView) {
        
        JRCollectionViewTitleModel *item = [self.titles objectAtIndex:indexPath.row];
        
        identifier = [JRTitleCollectionViewCell identifier];
        JRTitleCollectionViewCell *cell = (JRTitleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [cell setCellData:item];
        cell.backgroundColor =  [UIColor clearColor];
        [cell showAnimationOfProgress:1.f select:NO];
        if ([self.selectTitleMoel isEqual:item]) {
            [cell showAnimationOfProgress:1.f select:YES];
        }
        
        resultCell = cell;
    }
    
    return resultCell;
}

#pragma mark - @UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.titleCollectionView) {
        JRCollectionViewTitleModel *item = [self.titles objectAtIndex:indexPath.row];
        [self _changeTitle:item];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
    if (collectionView == self.titleCollectionView) {
        JRCollectionViewTitleModel *item = [self.titles objectAtIndex:indexPath.row];
        size = item.size;
        size.width += 20.f;
        return size;
    }
    return size;
}

@end
