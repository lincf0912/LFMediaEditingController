//
//  LFExtraAspectRatio.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2020/10/20.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFExtraAspectRatioProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFExtraAspectRatio : NSObject <LFExtraAspectRatioProtocol>

/** 横比例，例如9 */
@property (nonatomic, readonly) int lf_aspectWidth;
/** 纵比例，例如16 */
@property (nonatomic, readonly) int lf_aspectHeight;
/** 分隔符，默认x */
@property (nonatomic, copy, nullable, readonly) NSString *lf_aspectDelimiter;
/**
 适配视图纵横比例，默认YES
 如果视图的宽度>高度，则纵横比例会反转。
 */
@property (nonatomic, readonly) BOOL autoAspectRatio;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                          autoAspectRatio:(BOOL)autoAspectRatio;

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                       andAspectDelimiter:(NSString * _Nullable)aspectDelimiter
                          autoAspectRatio:(BOOL)autoAspectRatio;

- (instancetype)initWithWidth:(int)width
                    andHeight:(int)height
           andAspectDelimiter:(NSString * _Nullable)aspectDelimiter
              autoAspectRatio:(BOOL)autoAspectRatio;

@end

NS_ASSUME_NONNULL_END
