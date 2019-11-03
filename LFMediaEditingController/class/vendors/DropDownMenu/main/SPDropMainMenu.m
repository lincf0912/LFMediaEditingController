//
//  SPDropMenu.m
//  DropDownMenu
//
//  Created by TsanFeng Lam on 2019/8/29.
//  Copyright © 2019 SampleProjectsBooth. All rights reserved.
//

#import "SPDropMainMenu.h"
#import "SPBaseCollectionViewCell.h"

@interface SPDropMainMenu () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray<id <SPDropItemProtocol>> *m_items;

@property (nonatomic, weak) UIView *containView;

@property (nonatomic, weak) UICollectionView *MyCollectView;

@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) CGFloat arrowHeight;

@property (nonatomic, assign) CGPoint arrowPoint;

@property (nonatomic, assign) BOOL isShowInView;

@property (nonatomic, assign) CGFloat maxItemWidth;

@property (nonatomic, weak) UIView *bigView;

@end

@implementation SPDropMainMenu

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _customInit];
    }
    return self;
}

/**
 添加数据源
 */
- (void)addItem:(id <SPDropItemProtocol>)item
{
    if (item) {
        [self.m_items addObject:item];
    }
}

- (NSArray<id<SPDropItemProtocol>> *)items
{
    return [self.m_items mutableCopy];
}

- (void)setDirection:(SPDropMainMenuDirection)direction
{
    if (direction == SPDropMainMenuDirectionAuto) {
        direction = SPDropMainMenuDirectionBottom;
    }
    _direction = direction;
}

- (void)setContainerViewbackgroundColor:(UIColor *)containerViewbackgroundColor
{
    if (self.containView) {
        self.containView.backgroundColor = containerViewbackgroundColor;
    }
    _containerViewbackgroundColor = containerViewbackgroundColor;
}
#pragma mark - show

/**
 从坐标展示
 */
- (void)showFromPoint:(CGPoint)point
{
    [self showFromPoint:point animated:YES];
}
/**
 从坐标展示，动画
 */
- (void)showFromPoint:(CGPoint)point animated:(BOOL)animated
{
    self.isShowInView = NO;
    [self _showFromFrame:(CGRect){point, CGSizeZero} animated:animated];
}

/**
 从视图边缘展示
 */
- (void)showInView:(UIView *)view
{
    [self showInView:view animated:YES];
}
/**
 从视图边缘展示，动画
 */
- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    self.isShowInView = YES;
    
    /** 计算点 */
    CGRect converRect = [[UIApplication sharedApplication].keyWindow convertRect:view.frame fromView:view.superview];
    
    [self _showFromFrame:converRect animated:YES];

}

#pragma mark - hidden

/**
 隐藏菜单
 */
- (void)dismiss
{
    [self dismissWithAnimated:YES];
}
/**
 隐藏菜单，动画
 */
- (void)dismissWithAnimated:(BOOL)animated
{
    if (animated) {
        CGRect tempRect = self.frame;
        switch (self.direction) {
            case SPDropMainMenuDirectionTop:
            {
                tempRect.origin.y += CGRectGetHeight(tempRect);
            }
                break;
                
            default:
                break;
        }
        tempRect.size.height = 0.f;
        [UIView animateWithDuration:.25f animations:^{
            self.frame = tempRect;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.bigView removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
        [self.bigView removeFromSuperview];
    }
}

#pragma mark - Private Methods
- (void)_customInit
{
    _autoDismiss = YES;
    
    _displayMaxNum = 4;
    
    _m_items = [[NSMutableArray alloc] init];
    
    _margin = 10.f;
    
    _arrowHeight = 10.f;
    
    _maxItemWidth = 0.f;
    
    _direction = SPDropMainMenuDirectionBottom;

    _containerViewbackgroundColor = [UIColor blackColor];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self _createContainView];
}

#pragma mark 创建视图
- (void)_createContainView
{
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:aView];
    self.containView = aView;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 3;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.containView addSubview:collectionView];
    self.MyCollectView = collectionView;
    
    [self.MyCollectView registerClass:[SPBaseCollectionViewCell class] forCellWithReuseIdentifier:[SPBaseCollectionViewCell identifier]];
    
}

#pragma mark 圆角边
- (void)_drawCircleView
{
    CGSize cornerRadii = CGSizeMake(5.f, 5.f);
    
    CGFloat startY = 0.f;
    if (self.direction == SPDropMainMenuDirectionBottom) {
        startY = self.arrowHeight;
    }
        
    CGPoint arrowP = [self convertPoint:self.arrowPoint toView:self.containView];

    UIBezierPath * maskPath = [UIBezierPath bezierPath];
    
    
    /** 起始点（尖角点逆时针画图形） */
    CGPoint point1 = arrowP;
    /** 2 */
    CGPoint point2 = CGPointMake(arrowP.x + self.margin, CGRectGetHeight(self.containView.bounds)-self.margin);
    /** 3 */
    CGPoint point3 = CGPointMake(CGRectGetWidth(self.containView.frame) - cornerRadii.width, CGRectGetHeight(self.containView.bounds)-self.margin);
    /** 4 */
    CGPoint controlPoint1 = CGPointMake(CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.bounds)-self.margin);
    CGPoint point4 = CGPointMake(CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.bounds)-self.margin-cornerRadii.height);
    /** 5 */
    CGPoint point5 = CGPointMake(CGRectGetWidth(self.containView.frame), cornerRadii.height);
    /** 6 */
    CGPoint controlPoint2 = CGPointMake(CGRectGetWidth(self.containView.frame), 0.f);
    CGPoint point6 = CGPointMake(CGRectGetWidth(self.containView.frame) - cornerRadii.width, 0.f);
    /** 7 */
    CGPoint point7 = CGPointMake(cornerRadii.width, 0.f);
    /** 8 */
    CGPoint controlPoint3 = CGPointMake(0.f, 0.f);
    CGPoint point8 = CGPointMake(0.f, cornerRadii.height);
    /** 9 */
    CGPoint point9 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds)-cornerRadii.height-self.margin);
    /** 10 */
    CGPoint controlPoint4 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds)-self.margin);
    CGPoint point10 = CGPointMake(cornerRadii.width, CGRectGetHeight(self.containView.bounds)-self.margin);
    /** 11 */
    CGPoint point11 = CGPointMake(arrowP.x - self.margin, CGRectGetHeight(self.containView.bounds)-self.margin);

    if (self.direction == SPDropMainMenuDirectionBottom) {
        /** 2 */
        point2 = CGPointMake(arrowP.x - self.margin, self.margin);
        /** 3 */
        point3 = CGPointMake(cornerRadii.width, self.margin);
        /** 4 */
        controlPoint1 = CGPointMake(0.f, self.margin);
        point4 = CGPointMake(0.f, self.margin+cornerRadii.height);
        /** 5 */
        point5 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
        /** 6 */
        controlPoint2 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds));
        point6 = CGPointMake(cornerRadii.width, CGRectGetHeight(self.containView.bounds));
        /** 7 */
        point7 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, CGRectGetHeight(self.containView.bounds));
        /** 8 */
        controlPoint3 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds));
        point8 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
        /** 9 */
        point9 = CGPointMake(CGRectGetWidth(self.containView.bounds), self.margin + cornerRadii.height);
        /** 10 */
        controlPoint4 = CGPointMake(CGRectGetWidth(self.containView.bounds), self.margin);
        point10 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, self.margin);
        /** 11 */
        point11 = CGPointMake(arrowP.x + self.margin, self.margin);
        
    }
//    else if (self.menuDirection == SPDropMainMenuDirectionLeft) {
//        
//        /** 2 */
//        point2 = CGPointMake(arrowP.x + self.margin, arrowP.x + self.margin);
//        /** 3 */
//        point3 = CGPointMake(arrowP.x + self.margin, CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
//        /** 4 */
//        controlPoint1 = CGPointMake(arrowP.x + self.margin, CGRectGetHeight(self.containView.bounds));
//        point4 = CGPointMake(arrowP.x + self.margin + cornerRadii.width, CGRectGetHeight(self.containView.bounds));
//        /** 5 */
//        point5 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, CGRectGetHeight(self.containView.bounds));
//        /** 6 */
//        controlPoint2 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
//        point6 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds));
//        /** 7 */
//        point7 = CGPointMake(CGRectGetWidth(self.containView.bounds), cornerRadii.height);
//        /** 8 */
//        controlPoint3 = CGPointMake(CGRectGetWidth(self.containView.bounds), 0.f);
//        point8 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, 0.f);
//        /** 9 */
//        point9 = CGPointMake(cornerRadii.width + self.margin + arrowP.x, 0.f);
//        /** 10 */
//        controlPoint4 = CGPointMake(self.margin + arrowP.x, self.margin);
//        point10 = CGPointMake(cornerRadii.width + self.margin + arrowP.x, cornerRadii.height);
//        /** 11 */
//        point11 = CGPointMake(arrowP.x + self.margin, arrowP.x - self.margin);
//
//    } else if (self.menuDirection == SPDropMainMenuDirectionRight) {
//        /** 2 */
//        point2 = CGPointMake(arrowP.x - self.margin, self.margin);
//        /** 3 */
//        point3 = CGPointMake(cornerRadii.width, self.margin);
//        /** 4 */
//        controlPoint1 = CGPointMake(0.f, self.margin);
//        point4 = CGPointMake(0.f, self.margin+cornerRadii.height);
//        /** 5 */
//        point5 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
//        /** 6 */
//        controlPoint2 = CGPointMake(0.f, CGRectGetHeight(self.containView.bounds));
//        point6 = CGPointMake(cornerRadii.width, CGRectGetHeight(self.containView.bounds));
//        /** 7 */
//        point7 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, CGRectGetHeight(self.containView.bounds));
//        /** 8 */
//        controlPoint3 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds));
//        point8 = CGPointMake(CGRectGetWidth(self.containView.bounds), CGRectGetHeight(self.containView.bounds) - cornerRadii.height);
//        /** 9 */
//        point9 = CGPointMake(CGRectGetWidth(self.containView.bounds), self.margin + cornerRadii.height);
//        /** 10 */
//        controlPoint4 = CGPointMake(CGRectGetWidth(self.containView.bounds), self.margin);
//        point10 = CGPointMake(CGRectGetWidth(self.containView.bounds) - cornerRadii.width, self.margin);
//        /** 11 */
//        point11 = CGPointMake(arrowP.x + self.margin, self.margin);
//
//    }
    
    [maskPath moveToPoint:point1];
    [maskPath addLineToPoint:point2];
    [maskPath addLineToPoint:point3];
    [maskPath addQuadCurveToPoint:point4 controlPoint:controlPoint1];
    [maskPath addLineToPoint:point5];
    [maskPath addQuadCurveToPoint:point6 controlPoint:controlPoint2];
    [maskPath addLineToPoint:point7];
    [maskPath addQuadCurveToPoint:point8 controlPoint:controlPoint3];
    [maskPath addLineToPoint:point9];
    [maskPath addQuadCurveToPoint:point10 controlPoint:controlPoint4];
    [maskPath addLineToPoint:point11];

    /** 闭合 */
    [maskPath closePath];
    
    CAShapeLayer * maskLayer = [CAShapeLayer new];
    maskLayer.frame = self.containView.layer.bounds;
    maskLayer.path = maskPath.CGPath;
    self.containView.layer.mask = maskLayer;

}

#pragma mark 计算出菜单视图大小
- (CGRect)_calculateMenuViewFrameWithConverFrame:(CGRect)converFrame
{
    /** 计算尖角位置 */
    
    CGRect resultRect = CGRectZero;
    
    resultRect.origin = converFrame.origin;
    
    resultRect.size.width = [self maxItemWidth];
    
    

    if (self.displayMaxNum == 0) {
        self.displayMaxNum = self.items.count;
    }
    
    for (NSUInteger i = 0; i < self.displayMaxNum; i ++) {
            id<SPDropItemProtocol>obj = [self.items objectAtIndex:i];
        resultRect.size.height += (CGRectGetHeight(obj.displayView.frame)+((UICollectionViewFlowLayout *)self.MyCollectView.collectionViewLayout).minimumLineSpacing);
    }
    if (self.direction == SPDropMainMenuDirectionTop || self.direction == SPDropMainMenuDirectionBottom) {
        resultRect.size.height += (self.arrowHeight + self.margin);
    } else {
        resultRect.size.width += (self.margin + self.arrowHeight);
    }

    if (self.isShowInView) {
        
        resultRect.origin.x = CGRectGetMidX(converFrame)- CGRectGetWidth(resultRect)/2;
        resultRect.origin.y = CGRectGetMaxY(converFrame);
        
        if (self.direction == SPDropMainMenuDirectionTop) {
            resultRect.origin.y = (CGRectGetMinY(converFrame) - CGRectGetHeight(resultRect));
        }
        
    } else {
        
        resultRect.origin.x -= CGRectGetWidth(resultRect)/2;
        if (self.direction == SPDropMainMenuDirectionTop) {
            resultRect.origin.y -= CGRectGetHeight(resultRect);
        }
    }
    
    if (CGRectGetMinX(resultRect) < self.margin) {
        resultRect.origin.x = self.margin;
    }
     
    if (CGRectGetMaxX(resultRect) > (CGRectGetWidth([UIScreen mainScreen].bounds) - self.margin)) {
        resultRect.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - self.margin - CGRectGetWidth(resultRect);
    }
    
    
    return resultRect;
}

#pragma mark 计算视图
- (void)_calculateItemViews
{
    CGFloat totalHeight = 0.f;
    CGFloat maxHeight = 0.f;
    _maxItemWidth = 0.f;
    BOOL isOnlySelect = NO;
    for (id<SPDropItemProtocol>obj in self.m_items) {
        maxHeight = MAX(maxHeight, CGRectGetHeight(obj.displayView.frame));
        _maxItemWidth = MAX(_maxItemWidth, CGRectGetWidth(obj.displayView.frame));
        totalHeight += CGRectGetHeight(obj.displayView.frame);
        if (isOnlySelect) {
            obj.selected  = NO;
        }
        if (obj.selected) {
            isOnlySelect = YES;
        }
    }
}


#pragma mark 展示视图
- (void)_showFromFrame:(CGRect)frame animated:(BOOL)animated
{
    
    [self _calculateItemViews];

    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    self.bigView = view;
    UITapGestureRecognizer *tapGe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGe.delegate = self;
    [self.bigView addGestureRecognizer:tapGe];
    
    self.clipsToBounds = YES;
        
    [self.bigView addSubview:self];
    
    CGRect rect = [self _calculateMenuViewFrameWithConverFrame:frame];
    
    self.frame = rect;
    
    CGPoint point = CGPointZero;
    if (self.isShowInView) {
        
        point = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame));
        if (self.direction == SPDropMainMenuDirectionTop) {
            point = CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame));
        }
        point = [self convertPoint:point fromView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        
        point = [self convertPoint:frame.origin fromView:[UIApplication sharedApplication].keyWindow];
        
    }
    
    if (point.x < self.margin*2) {
        point.x = self.margin*2;
    } else if (point.x > (CGRectGetWidth(self.bounds) - self.margin*2)) {
        point.x = (CGRectGetWidth(self.bounds) - self.margin*2);
    }
    
    self.arrowPoint = point;
    
    if (self.direction == SPDropMainMenuDirectionTop) {
        self.containView.frame = CGRectMake(0.f, self.margin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-self.margin);
        self.MyCollectView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame)-self.margin);
    } else if (self.direction == SPDropMainMenuDirectionBottom) {
        self.containView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-self.margin);
        self.MyCollectView.frame = CGRectMake(0.f, self.margin, CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame)-self.margin);
    }
        
    [self _drawCircleView];

    self.containView.backgroundColor = self.containerViewbackgroundColor;

    CGRect tempRect = self.frame;
    
    if (animated) {
        CGRect zeroRect = tempRect;

        switch (self.direction) {
            case SPDropMainMenuDirectionTop:
            {
                zeroRect.size.height = 0.f;
                zeroRect.origin.y += CGRectGetHeight(tempRect);
            }
                break;
            case SPDropMainMenuDirectionBottom:
            {
                zeroRect.size.height = 0.f;
            }
                break;
            default:
                break;
        }
        self.frame = zeroRect;
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.25f animations:^{
            weakSelf.frame = tempRect;
        }];
    }

    for (id<SPDropItemProtocol>obj in self.m_items) {
        if (obj.selected) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.m_items indexOfObject:obj] inSection:0];
            [self.MyCollectView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop) animated:NO];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.bigView];
    CGRect rect = [self.MyCollectView.superview convertRect:self.MyCollectView.frame toView:self.bigView];
    if (CGRectContainsPoint(rect, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<SPDropItemProtocol>obj = [self.items objectAtIndex:indexPath.row];
    return obj.displayView.frame.size;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for (id<SPDropItemProtocol>obj in self.items) {
        obj.selected = NO;
    }
    {
        id<SPDropItemProtocol>obj = [self.items objectAtIndex:indexPath.row];
        obj.tapHandler(obj);
        obj.selected = YES;
        [self dismiss];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SPBaseCollectionViewCell identifier];
    SPBaseCollectionViewCell *cell = (SPBaseCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    id<SPDropItemProtocol>obj = [self.items objectAtIndex:indexPath.row];
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    [cell.contentView addSubview:obj.displayView];
    
    return cell;
}

@end
