//
//  JRTitleCollectionViewCell.h
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface JRTitleCollectionViewCell : JRBaseCollectionViewCell

- (void)showAnimationOfProgress:(CGFloat)progress select:(BOOL)select;

@end

NS_ASSUME_NONNULL_END
