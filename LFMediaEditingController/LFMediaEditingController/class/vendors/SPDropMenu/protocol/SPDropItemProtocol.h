//
//  SPDropItemProtocol.h
//  DropDownMenu
//
//  Created by TsanFeng Lam on 2019/8/29.
//  Copyright © 2019 SampleProjectsBooth. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SPDropItemProtocol;

typedef void(^SPDropItemTapHandler)(id <SPDropItemProtocol> item);
typedef void(^SPDropItemDoubleTapHandler)(id <SPDropItemProtocol> item);
typedef void(^SPDropItemLongPressHandler)(id <SPDropItemProtocol> item);

@protocol SPDropItemProtocol <NSObject>

@required
@property (nonatomic, readonly) UIView *displayView;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, copy, nullable) SPDropItemTapHandler tapHandler;
@property (nonatomic, copy, nullable) SPDropItemDoubleTapHandler doubleTapHandler;
@property (nonatomic, copy, nullable) SPDropItemLongPressHandler longPressHandler;

@end

NS_ASSUME_NONNULL_END
