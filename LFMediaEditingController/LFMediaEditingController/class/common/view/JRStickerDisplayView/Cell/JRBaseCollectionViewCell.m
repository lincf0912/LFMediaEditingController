//
//  JRBaseCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"

@interface JRBaseCollectionViewCell ()

@property (strong, nonatomic) id cellData;

@end

@implementation JRBaseCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (void)setCellData:(nullable id)data
{
    _cellData = data;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _cellData = nil;
}
@end
