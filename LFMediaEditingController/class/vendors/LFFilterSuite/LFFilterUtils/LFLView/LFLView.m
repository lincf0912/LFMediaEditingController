//
//  LFLView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/17.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFLView.h"

@interface LFLViewContext : NSObject <CALayerDelegate>

@property(nonatomic, strong) NSMutableArray <__kindof UIImage *> *images;
@property(nonatomic, assign) int rows;
@property(nonatomic, assign) int columns;
@property(nonatomic, assign) CGSize tileSize;
@property(nonatomic, assign) CGRect imageBounds;

- (instancetype)initWithImage:(UIImage *)image;
- (void)configurationcontextWithImage:(UIImage *)image;

@end

@implementation LFLViewContext

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        [self configurationcontextWithImage:image];
    }
    return self;
}

- (void)configurationcontextWithImage:(UIImage *)image
{
    NSMutableArray *images = [NSMutableArray array];
    CGImageRef imageToC = image.CGImage;
    CGSize tileSize = CGSizeMake(256, 256);
    CGRect imageBounds = CGRectMake(0, 0, CGImageGetWidth(imageToC), CGImageGetHeight(imageToC));
    int rows = ceil(imageBounds.size.height/tileSize.height);
    int columns = ceil(imageBounds.size.width/tileSize.width);
    for (int row = 0; row < rows; row++)
    {
        for (int column = 0; column < columns; column++)
        {
            CGRect tileRect = CGRectMake(tileSize.width*column, tileSize.height*row, MIN(tileSize.width, imageBounds.size.width - tileSize.width*column), MIN(tileSize.height, imageBounds.size.height - tileSize.height*row));
            CGImageRef tileImage = CGImageCreateWithImageInRect(imageToC, tileRect);
            
            [images addObject:[UIImage imageWithCGImage:tileImage]];
            CGImageRelease(tileImage);
            
        }
    }
    self.images = images;
    self.rows = rows;
    self.columns = columns;
    self.tileSize = tileSize;
    self.imageBounds = imageBounds;
}

#pragma mark - CALayerDelegate
/*
 layer代理设置为此对象bounds的size是tileSize/layer.contentsScale设置为其它则不一样
 */
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGRect bounds = CGContextGetClipBoundingBox(ctx);
    CGFloat contentsScale = ((CATiledLayer*)layer).contentsScale;
    CGFloat pieTileWidth = self.tileSize.width / contentsScale;
    CGFloat pieTileHeight = self.tileSize.height / contentsScale;
    int row = round(bounds.origin.y/pieTileWidth);
    int column = round(bounds.origin.x/pieTileHeight);
    NSInteger index = row * self.columns + column;
    if (index >=0  && index < self.images.count && row < self.rows && column < self.columns) {
        UIGraphicsPushContext(ctx);
        [self.images[index] drawInRect:bounds];
        UIGraphicsPopContext();
    }
}

@end

@interface LFLView ()

@property (nonatomic, strong) LFLViewContext *context;

@end

@implementation LFLView

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (instancetype)initWithImage:(nullable UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if (!_context) {
        _context = [[LFLViewContext alloc] initWithImage:image];
    } else {
        [_context configurationcontextWithImage:image];
    }
    
    [self.layer setContentsScale:1.0f];
    self.layer.delegate = self.context;
    [(CATiledLayer *)self.layer setTileSize:self.context.tileSize];
    
    CGRect frame = self.frame;
    CGFloat normalSizeScale = MIN(1, MIN(self.frame.size.width/self.context.imageBounds.size.width, self.frame.size.height/self.context.imageBounds.size.height));
    self.transform = CGAffineTransformMakeScale(normalSizeScale, normalSizeScale);
    self.frame = frame;
    
    [self.layer setNeedsDisplay];
}

@end
