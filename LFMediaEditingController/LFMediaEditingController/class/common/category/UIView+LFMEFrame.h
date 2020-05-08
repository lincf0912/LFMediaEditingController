//
//  UIView+LFFrame.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LFMEFrame)

@property (nonatomic, assign) CGFloat lfme_x;
@property (nonatomic, assign) CGFloat lfme_y;
@property (nonatomic, assign) CGFloat lfme_centerX;
@property (nonatomic, assign) CGFloat lfme_centerY;
@property (nonatomic, assign) CGFloat lfme_width;
@property (nonatomic, assign) CGFloat lfme_height;
@property (nonatomic, assign) CGSize lfme_size;
@property (nonatomic, assign) CGPoint lfme_origin;

@end
