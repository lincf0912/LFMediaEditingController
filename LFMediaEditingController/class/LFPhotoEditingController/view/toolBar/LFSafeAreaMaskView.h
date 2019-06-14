//
//  LFSafeAreaMaskView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFSafeAreaMaskView : UIView

@property (nonatomic, setter=setMaskRect:) CGRect maskRect;
@property (nonatomic, assign) BOOL showMaskLayer;

@end

NS_ASSUME_NONNULL_END
