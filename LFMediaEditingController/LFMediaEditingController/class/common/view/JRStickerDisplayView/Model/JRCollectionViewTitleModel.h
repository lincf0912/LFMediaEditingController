//
//  JRCollectionViewTitleModel.h
//  StickerBooth
//
//  Created by djr on 2020/3/12.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRCollectionViewTitleModel : NSObject

@property (nonatomic, readonly) NSString *title;

@property (nonatomic, assign, readonly) CGSize size;

@property (nonatomic, strong, readonly) UIFont *font;

- (instancetype)initWithTitle:(NSString *)title;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
