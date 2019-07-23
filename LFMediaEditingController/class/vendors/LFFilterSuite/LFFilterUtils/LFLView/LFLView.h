//
//  LFLView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/17.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFLView : UIView

- (instancetype)initWithImage:(nullable UIImage *)image;

@property (nonatomic, assign) CGSize tileSize;

@property (nullable, nonatomic, strong) UIImage *image; // default is nil

@end

NS_ASSUME_NONNULL_END
