//
//  LFStickerContent.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2020/2/25.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * LFStickerContentStringKey NS_EXTENSIBLE_STRING_ENUM;

/**
 默认贴图
 defalut sticker
 */
extern LFStickerContentStringKey const LFStickerContentDefaultSticker;
/**
 默认全部相册图片
 all album photo
 */
extern LFStickerContentStringKey const LFStickerContentAllAlbum;

extern NSString *LFStickerCustomAlbum(NSString *name);

@interface LFStickerContent : NSObject

/** 标题 */
@property (nonatomic, readonly) NSString *title;
/**
 贴图内容
     LFStickerContentStringKey
     内置数据类型：
     1、NSURL *
        分为多种数据：
        1、完整的本地资源路径目录file://...。将该目录下的所有后缀为@"png", @"jpg", @"jpeg", @"gif"的文件作为贴图资源（不包含子目录）。
        2、完整的本地资源路径文件file://.../image.png。
        3、完整的网络资源路径文件http://...。
     2、NSString *
        自定义相册名称LFStickerCustomAlbum(@"动画")。
     3、PHAsset *
        相册资源，仅支持PHAssetMediaTypeImage类型。（支持iOS8或之后）
 
 ===============================================================================================================
 
 Sticker Content
     LFStickerContentStringKey
     Built-in data types:
     1.NSURL *
        divided into multiple data.
        1. The local resource path directory file://... .All files in this directory with the suffixes @ "png", @ "jpg", @ "jpeg", @ "gif" are used as sticker resources (Without subdirectories).
        2. The local resource path file file://.../image.png .
        3. The network resource path file http://... .
     2.NSString *
        Customize the album name LFStickerCustomAlbum(@"Aminated").
     3.PHAsset *
        Photo album resource. Only PHAssetMediaTypeImage type is supported. (supports iOS8 or later)
 */
@property (nonatomic, readonly) NSArray <id /* LFStickerContentStringKey / NSString * / NSURL * / PHAsset * */> *contents;


+ (instancetype)stickerContentWithTitle:(NSString *)title contents:(NSArray *)contents;
- (instancetype)initWithTitle:(NSString *)title contents:(NSArray *)contents;

@end

NS_ASSUME_NONNULL_END
