//
//  JRImgObj.h
//  JRCollectionView
//
//  Created by Mr.D on 2018/8/6.
//  Copyright © 2018年 Mr.D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JRFilterModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) NSInteger effectType;


@end
