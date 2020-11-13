//
//  LFText.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/4/5.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFText : NSObject <NSSecureCoding>

//@property (nonatomic, copy) NSString *text;
//@property (nonatomic, strong) UIFont *font;
//@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) NSAttributedString *attributedText;

@property (nonatomic, strong) NSDictionary *layoutData;
/**
 Default is CGRectNull.
 因为使用attributedText计算文字大小与实际在UITextView的大小会有差异，原因是UITextView -> NSTextContainer -> lineFragmentPadding 的默认值为5，导致计算的宽度相差10。高度也有差异，原因不明。这里直接使用UITextView返回的文字区域。
 */
@property (nonatomic, assign) CGRect usedRect;

@end
