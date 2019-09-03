//
//  LFStampBrush.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFStampBrush : LFBrush

/** 印章图案名称 */
@property (nonatomic, strong) NSArray <NSString *> *patterns;

@end

NS_ASSUME_NONNULL_END
