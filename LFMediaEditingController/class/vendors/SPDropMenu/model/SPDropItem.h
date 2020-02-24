//
//  SPDropItem.h
//  DropDownMenu
//
//  Created by TsanFeng Lam on 2019/8/29.
//  Copyright © 2019 SampleProjectsBooth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDropItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SPDropItemState) {
    SPDropItemStateNormal,
    SPDropItemStateSelected,
};

@interface SPDropItem : NSObject <SPDropItemProtocol>

@property (nonatomic, copy) NSString *title;
- (void)setTitleColor:(nullable UIColor *)color forState:(SPDropItemState)state;
- (void)setImage:(nullable UIImage *)image forState:(SPDropItemState)state;

- (nullable UIColor *)colorForState:(SPDropItemState)state;
- (nullable UIImage *)imageForState:(SPDropItemState)state;

@end

NS_ASSUME_NONNULL_END
