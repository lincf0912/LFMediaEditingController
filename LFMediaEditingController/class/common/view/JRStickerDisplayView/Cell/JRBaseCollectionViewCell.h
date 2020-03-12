//
//  JRBaseCollectionViewCell.h
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRBaseCollectionViewCell : UICollectionViewCell

@property (readonly, nonatomic) id cellData;

+ (NSString *)identifier;

- (void)setCellData:(nullable id)data;

@end

NS_ASSUME_NONNULL_END
