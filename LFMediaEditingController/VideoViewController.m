//
//  VideoViewController.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LFVideoEditingController.h"
#import "AVAsset+LFMECommon.h"

@interface VideoViewController () <LFVideoEditingControllerDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *firstImage;
/** 需要保存到编辑数据 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    /** 拍摄视频 */
//    self.url = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"];
    /** 非拍摄视频 */
    //  self.url = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"m4v"];
    /** 相册视频（方向不正确） */
    self.url = [[NSBundle mainBundle] URLForResource:@"4" withExtension:@"MOV"];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.url options:nil];
    self.firstImage = [asset lf_firstImage:nil];
    _player = [AVPlayer playerWithURL:self.url];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:playerLayer];
    _playerLayer = playerLayer;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(videoEditing)];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    CGFloat top = self.view.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height;
    self.playerLayer.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y+top, self.view.bounds.size.width, self.view.bounds.size.height-top-self.view.safeAreaInsets.bottom);
}

- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"status"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _playerLayer.frame = self.view.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        } else {
            NSLog(@"视频解析失败!");
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)videoEditing
{
    LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
    lfVideoEditVC.delegate = self;
//    lfVideoEditVC.operationType = LFVideoEditOperationType_draw | LFVideoEditOperationType_clip;
//    lfVideoEditVC.minClippingDuration = 3;
//    lfVideoEditVC.defaultOperationType = LFVideoEditOperationType_clip;
//    lfVideoEditVC.operationAttrs = @{
//                                     LFVideoEditDrawColorAttributeName:@(LFVideoEditOperationSubTypeDrawVioletRedColor),
////                                     LFVideoEditStickerAttributeName:@"描述（贴图路径）",
//                                     LFVideoEditTextColorAttributeName:@(LFVideoEditOperationSubTypeTextAzureColor),
//                                     LFVideoEditFilterAttributeName:@(LFVideoEditOperationSubTypeProcessFilter),
//                                     LFVideoEditAudioMuteAttributeName:@(true),
////                                     LFVideoEditAudioUrlsAttributeName:@"描述（音频路径）",
//                                     LFVideoEditRateAttributeName:@(0.5),
//                                     LFVideoEditClipMinDurationAttributeName:@(2),
//                                     LFVideoEditClipMaxDurationAttributeName:@(5)
//                                     };
    if (self.videoEdit) {
        lfVideoEditVC.videoEdit = self.videoEdit;
    } else {
        [lfVideoEditVC setVideoURL:self.url placeholderImage:self.firstImage];
    }
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:lfVideoEditVC animated:NO];
    [self.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - LFVideoEditingControllerDelegate
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self.player removeObserver:self forKeyPath:@"status"];
    if (videoEdit && videoEdit.editFinalURL) {
        self.player = [AVPlayer playerWithURL:videoEdit.editFinalURL];
    } else {
        self.player = [AVPlayer playerWithURL:self.url];
    }
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _playerLayer.player = self.player;
    self.videoEdit = videoEdit;
}

@end
