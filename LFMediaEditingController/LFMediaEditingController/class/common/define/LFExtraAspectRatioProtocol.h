//
//  LFExtraAspectRatioProtocol.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2020/10/20.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 命名描述见LFImagePickerController.strings */
@protocol LFExtraAspectRatioProtocol <NSObject>
/** 横比例，例如9 */
@property (nonatomic, assign) int lf_aspectWidth;
/** 纵比例，例如16 */
@property (nonatomic, assign) int lf_aspectHeight;
/** 分隔符，默认x */
@property (nonatomic, copy, nullable) NSString *lf_aspectDelimiter;

@end

NS_ASSUME_NONNULL_END
