//
//  JRCollectionViewTitleModel.m
//  StickerBooth
//
//  Created by djr on 2020/3/12.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRCollectionViewTitleModel.h"

NSString * const JRCollectionViewTitleModel_title = @"JRCollectionViewTitleModel_title";
NSString * const JRCollectionViewTitleModel_size = @"JRCollectionViewTitleModel_size";

@implementation JRCollectionViewTitleModel

- (UIFont *)font
{
    return [UIFont systemFontOfSize:16.f];
}


- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        [self _jr_setTitle:title];
    } return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _title = [dictionary objectForKey:JRCollectionViewTitleModel_title];
        _size = CGSizeFromString([dictionary objectForKey:JRCollectionViewTitleModel_size]);
    } return self;
}

- (NSDictionary *)dictionary
{
    if (_title == nil) {
        _title = @"";
    }
    return @{JRCollectionViewTitleModel_title:_title, JRCollectionViewTitleModel_size:NSStringFromCGSize(_size)};
}

#pragma mark - Private Methods
- (void)_jr_setTitle:(NSString *)title
{
    _title = title;
    if (_title == nil) {
        _size = CGSizeZero;
        return;
    }
    NSDictionary *btAtt = @{NSFontAttributeName:self.font};
    _size = [title sizeWithAttributes:btAtt];
}

@end


