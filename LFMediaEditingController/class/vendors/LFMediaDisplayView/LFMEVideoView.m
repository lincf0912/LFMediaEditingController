//
//  LFMEVideoView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEVideoView.h"
#import "NSBundle+LFMediaDisplayView.h"

static char* CSVideoStatusChanged = "VideoStatusChanged";

@interface LFMEVideoView ()
{
    AVPlayerItem *_oldItem;
}
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, strong) UIImage *playImage;

@end

@implementation LFMEVideoView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _playButton.frame = self.bounds;
}

- (void)dealloc
{
    [self unsetupAVPlay];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    ((AVPlayerLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspect;
    _playImage = [NSBundle LFMD_imageNamed:@"CSVideoPlay.png"];
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:self.playImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.shadowOpacity = .8;
        button.layer.shadowRadius = 3.0;
        button.layer.shadowColor = [UIColor whiteColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(1, 1);
        [self addSubview:button];
        _playButton = button;
    }
}

- (void)playAction:(UIButton *)sender
{
    if (self.isPlaying) {
        [self.player pause];
        [sender setImage:self.playImage forState:UIControlStateNormal];
    } else {
        [self.player play];
        [sender setImage:nil forState:UIControlStateNormal];
    }
    
}

- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    [self setupAVPlay];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CSVideoStatusChanged) {
        void (^block)(void) = ^{
            switch (self.player.status) {
                case AVPlayerStatusReadyToPlay:
                {
                    ((AVPlayerLayer *)self.layer).player = self.player;
                }
                    break;
                case AVPlayerStatusFailed:
                {
                    AVPlayerItem *playerItem = (AVPlayerItem *)object;
                    NSLog(@"AVPlayerStatusFailed:%@", playerItem.error);
                }
                default:
                    NSLog(@"AVPlayerStatusUnknown");
                    break;
            }
        };
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}


#pragma mark - AVPlay

- (void)setupAVPlay {
    [self unsetupAVPlay];
    
    if (_player == nil) {
        _oldItem = [AVPlayerItem playerItemWithAsset:self.asset];
        [_oldItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:CSVideoStatusChanged];
        _player = [[AVPlayer alloc] initWithPlayerItem:_oldItem];
        
        /* When the player item has played to its end time we'll toggle
         the movie controller Pause button to be the Play button */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_oldItem];
    }
}

- (void)unsetupAVPlay {
    if (_oldItem != nil) {
        [_oldItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_oldItem];
        _oldItem = nil;
        
    }
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.playButton setImage:self.playImage forState:UIControlStateNormal];
}

#pragma mark - public
- (BOOL)isPlaying {
    return self.player.rate > 0;
}

- (CMTime)itemDuration {
    return CMTimeMultiply(self.player.currentItem.duration, 1.f);
}

- (CMTime)playableDuration {
    AVPlayerItem * item = self.player.currentItem;
    CMTime playableDuration = kCMTimeZero;
    
    if (item.status != AVPlayerItemStatusFailed) {
        for (NSValue *value in item.loadedTimeRanges) {
            CMTimeRange timeRange = [value CMTimeRangeValue];
            
            playableDuration = CMTimeAdd(playableDuration, timeRange.duration);
        }
    }
    
    return playableDuration;
}

@end
