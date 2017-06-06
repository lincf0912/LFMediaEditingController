//
//  LFStickerBar.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/21.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFStickerBarDelegate;

@interface LFStickerBar : UIView;

@property (nonatomic, weak) id <LFStickerBarDelegate> delegate;

@end

@protocol LFStickerBarDelegate <NSObject>

- (void)lf_stickerBar:(LFStickerBar *)lf_stickerBar didSelectImage:(UIImage *)image;

@end
