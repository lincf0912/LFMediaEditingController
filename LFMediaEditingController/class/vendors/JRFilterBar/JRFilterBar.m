//
//  JRStrainImageShowView.m
//  JRCollectionView
//
//  Created by Mr.D on 2018/8/2.
//  Copyright © 2018年 Mr.D. All rights reserved.
//

#import "JRFilterBar.h"
#import "JRFilterModel.h"
#import "JRFilterBarCell.h"

CGFloat const JR_FilterBar_MAX_WIDTH = 60.f;

@interface JRFilterBar () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (assign, nonatomic) CGSize cellSize;
@property (nonatomic, strong) NSMutableArray <JRFilterModel *>*list;
@property (nonatomic, strong) JRFilterModel *selectModel;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIView *backgroundView;

@end

@implementation JRFilterBar


- (instancetype)initWithFrame:(CGRect)frame defalutEffectType:(NSInteger)defalutEffectType dataSource:(NSArray<NSNumber *> *)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        _list = @[].mutableCopy;
        _defaultColor = [UIColor grayColor];
        _selectColor = [UIColor blueColor];
        [self _createDataSource:dataSource];
        [self _createCustomView_jr];
    } return self;
}

#pragma mark - System Methods
- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11, *)) {
        CGRect rect = self.bounds;
        rect.size.height -= self.safeAreaInsets.bottom;
        _backgroundView.frame = rect;
        _collectionView.frame = _backgroundView.bounds;
        _cellSize = CGSizeMake(JR_FilterBar_MAX_WIDTH, CGRectGetHeight(_backgroundView.frame));
        [_collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - Private Methods

#pragma mark 创建collectionView
- (void)_createCustomView_jr {
    UIView *aView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:aView];
    _backgroundView = aView;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:_backgroundView.bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 11.0, *)){
        [collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [_backgroundView addSubview:collectionView];
    [collectionView registerClass:[JRFilterBarCell class] forCellWithReuseIdentifier: [JRFilterBarCell identifier]];
    _collectionView = collectionView;
    [self _scrollView_jr];
}

#pragma mark 创建数据源
- (void)_createDataSource:(NSArray <NSNumber *>*)typeCollects {
    for (NSNumber *number in typeCollects) {
        JRFilterModel *obj = [JRFilterModel new];
        obj.effectType = [number integerValue];
        [self.list addObject:obj];
        if (_defalutEffectType == obj.effectType) {
            self.selectModel = obj;
        }
    }
    if (self.selectModel == nil) {
        self.selectModel = self.list.firstObject;
    }
}

#pragma mark 滚动
- (void)_scrollView_jr {
    if (self.selectModel) {
        NSInteger index = [self.list indexOfObject:self.selectModel];
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:selectIndexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JRFilterModel *item = [_list objectAtIndex:indexPath.row];
    if (_selectModel) {
        NSInteger index = [_list indexOfObject:_selectModel];
        _selectModel = nil;
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
    }
    _selectModel = item;
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self _scrollView_jr];
    if ([self.delegate respondsToSelector:@selector(jr_filterBar:didSelectImage:effectType:)]) {
        [self.delegate jr_filterBar:self didSelectImage:item.image effectType:item.effectType];
    }

}
#pragma mark - UICollectionViewDelegate
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    JRFilterBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[JRFilterBarCell identifier] forIndexPath:indexPath];
    JRFilterModel *item = [_list objectAtIndex:indexPath.row];
    cell.defaultColor = self.defaultColor;
    cell.selectColor = self.selectColor;
    if (!item.image) {
        if ([self.dataSource respondsToSelector:@selector(jr_filterBarImageForEffectType:)]) {
            item.image = [self.dataSource jr_filterBarImageForEffectType:item.effectType];
        }
    }
    if (!item.name) {
        if ([self.dataSource respondsToSelector:@selector(jr_filterBarNameForEffectType:)]) {
            item.name = [self.dataSource jr_filterBarNameForEffectType:item.effectType];
        }
    }
    cell.isSelectedModel = [item isEqual:_selectModel];
    [cell setCellData:item];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _list.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
@end
