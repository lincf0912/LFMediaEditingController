//
//  JRCollectionViewCell.h
//  gifDemo
//
//  Created by djr on 2020/2/19.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JRCollectionViewDelegate;

@interface JRCollectionViewCell : JRBaseCollectionViewCell

- (void)setCellData:(id)data index:(NSInteger)index;
@property (weak, nonatomic) id<JRCollectionViewDelegate>delegate;

@end

@protocol JRCollectionViewDelegate <NSObject>

@optional
- (void)didSelectData:(nullable NSData *)data thumbnailImage:(nullable UIImage *)thumbnailImage index:(NSInteger)index;

- (void)didEndReloadData:(JRCollectionViewCell *)cell;

@end

NS_ASSUME_NONNULL_END
