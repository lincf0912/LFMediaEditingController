//
//  LFMEVideoView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEVideoView.h"

static char* CSVideoStatusChanged = "VideoStatusChanged";

@interface LFMEVideoView ()
{
    AVPlayerItem *_oldItem;
}

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
}

- (void)dealloc
{
    [_player pause];
    [self unsetupAVPlay];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    ((AVPlayerLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)setAsset:(AVAsset *)asset
{
    if (_asset != asset) {
        [self unsetupAVPlay];
        _asset = asset;
        [self setupAVPlay];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CSVideoStatusChanged) {
        void (^block)(void) = ^{
            switch (self.player.status) {
                case AVPlayerStatusReadyToPlay:
                {
                    ((AVPlayerLayer *)self.layer).player = self.player;
                    [self.player play];
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
    
    _oldItem = [AVPlayerItem playerItemWithAsset:self.asset];
    [_oldItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:CSVideoStatusChanged];
    if (_player == nil) {
        _player = [[AVPlayer alloc] initWithPlayerItem:_oldItem];
    } else {
        [_player pause];
        [_player replaceCurrentItemWithPlayerItem:_oldItem];
    }
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_oldItem];
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
