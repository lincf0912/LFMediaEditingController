//
//  LFExtraAspectRatioProtocol.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2020/10/20.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 组合名称name=$lf_aspectWidth+$lf_aspectDelimiter+$lf_aspectHeight 重命名规则描述见LFImagePickerController.strings */
@protocol LFExtraAspectRatioProtocol <NSObject>
/** 横比例，例如9 */
@property (nonatomic, readonly) int lf_aspectWidth;
/** 纵比例，例如16 */
@property (nonatomic, readonly) int lf_aspectHeight;
/** 分隔符，默认x */
@property (nonatomic, copy, nullable, readonly) NSString *lf_aspectDelimiter;
/**
 适配视图纵横比例
 如果视图的宽度>高度，则纵横比例会反转。
 */
@property (nonatomic, readonly) BOOL autoAspectRatio;

@end

NS_ASSUME_NONNULL_END
