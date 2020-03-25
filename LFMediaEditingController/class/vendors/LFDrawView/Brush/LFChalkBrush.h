//
//  LFChalkBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFPaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFChalkBrush : LFPaintBrush


/// 创建粉笔画笔
/// @param name 粉笔图片
- (instancetype)initWithImageName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
