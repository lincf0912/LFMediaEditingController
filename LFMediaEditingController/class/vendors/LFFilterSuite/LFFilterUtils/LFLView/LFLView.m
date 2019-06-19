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

@property(nonatomic, strong) NSOperationQueue *queue;

- (void)configurationcontextWithImage:(UIImage *)image completionBlock:(void (^)(void))completionBlock;

@end

@implementation LFLViewContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)configurationcontextWithImage:(UIImage *)image completionBlock:(void (^)(void))completionBlock
{
    self.queue.operations.firstObject.completionBlock = nil;
    [self.queue.operations.firstObject cancel];
    
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
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
        weakSelf.images = images;
        weakSelf.rows = rows;
        weakSelf.columns = columns;
        weakSelf.tileSize = tileSize;
        weakSelf.imageBounds = imageBounds;
    }];
    
    [operation setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock();
            }
        });
    }];
    
    [self.queue addOperation:operation];
    
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = [LFLViewContext new];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _context = [LFLViewContext new];
    }
    return self;
}

- (instancetype)initWithImage:(nullable UIImage *)image
{
    self = [self init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    __weak typeof(self) weakSelf = self;
    [_context configurationcontextWithImage:image completionBlock:^{
        
        [weakSelf.layer setContentsScale:1.0f];
        weakSelf.layer.delegate = self.context;
        [(CATiledLayer *)weakSelf.layer setTileSize:weakSelf.context.tileSize];
        
        CGRect frame = self.frame;
        CGFloat normalSizeScale = MIN(1, MIN(weakSelf.frame.size.width/weakSelf.context.imageBounds.size.width, self.frame.size.height/weakSelf.context.imageBounds.size.height));
        weakSelf.transform = CGAffineTransformMakeScale(normalSizeScale, normalSizeScale);
        weakSelf.frame = frame;
        
        [weakSelf.layer setNeedsDisplay];
    }];
    
}

@end
