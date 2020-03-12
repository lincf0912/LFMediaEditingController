//
//  JRDataImageView.h
//  StickerBooth
//
//  Created by djr on 2020/3/4.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRDataImageView : UIImageView

- (void)jr_dataForImage:(nullable NSData *)data;

@property (nonatomic, readonly) BOOL isGif;

@end

NS_ASSUME_NONNULL_END
