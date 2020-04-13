//
//  NSData+CompressDecodedImage.h
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/3/10.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CompressDecodedImage)

- (UIImage * __nullable)dataDecodedImageWithSize:(CGSize)size mode:(UIViewContentMode)mode;

@end

NS_ASSUME_NONNULL_END
