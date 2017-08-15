//
//  LFAudioTrackBar.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/8/10.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFAudioTrackBar.h"
#import "LFMediaEditingHeader.h"
#import "UIView+LFMEFrame.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation LFAudioItem


@end


@interface LFAudioTrackCell : UITableViewCell



@end

@implementation LFAudioTrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.multipleSelectionBackgroundView = [[UIView alloc] init];
    }
    return self;
}

@end

@interface LFAudioTrackBar () <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate>

@property (nonatomic, assign) CGFloat customToolbarHeight;

@property (nonatomic, strong) NSMutableArray <LFAudioItem *> *m_audioUrls;
@property (nonatomic, strong) NSMutableArray <LFAudioItem *> *m_select_audioUrls;

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation LFAudioTrackBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame layout:nil];
}

- (instancetype)initWithFrame:(CGRect)frame layout:(void (^)(LFAudioTrackBar *audioTrackBar))layoutBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        _customToolbarHeight = 44.f;
        _customTopbarHeight = 64.f;
        if (layoutBlock) {
            layoutBlock(self);
        }
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.f];
    _m_audioUrls = [@[] mutableCopy];
    _m_select_audioUrls = [@[] mutableCopy];
    
    [self configCustomNaviBar];
    [self configTableView];
    [self configToolbar];
}

- (void)configCustomNaviBar
{
    /** 顶部栏 */
    CGFloat margin = 5;
    CGFloat size = _customTopbarHeight - margin*2;
    UIView *topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, _customTopbarHeight)];
    topbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    topbar.backgroundColor = [UIColor clearColor];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [self.cancelButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _customTopbarHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 2;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin*2, margin, editCancelWidth, size)];
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = font;
    [cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat editOkWidth = [self.oKButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _customTopbarHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 5;
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - (editOkWidth+margin*2), margin, editOkWidth, size)];
    finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [finishButton setTitle:self.oKButtonTitle forState:UIControlStateNormal];
    finishButton.titleLabel.font = font;
    [finishButton setTitleColor:self.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [topbar addSubview:cancelButton];
    [topbar addSubview:finishButton];
    
    [self addSubview:topbar];
}

- (void)configTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _customTopbarHeight, self.width, self.height-_customTopbarHeight-_customToolbarHeight) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    /** 这个设置iOS9以后才有，主要针对iPad，不设置的话，分割线左侧空出很多 */
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    /** 解决ios7中tableview每一行下面的线向右偏移的问题 */
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.allowsSelection = NO;
    tableView.allowsMultipleSelectionDuringEditing = YES;
    
    tableView.editing = YES;
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (void)configToolbar
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-_customToolbarHeight, self.width, _customToolbarHeight)];
    
    CGFloat rgb = 34 / 255.0;
    toolbar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    CGSize size = CGSizeMake(44, toolbar.frame.size.height);
    CGFloat margin = 10.f;
    
    /** 左 */
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = (CGRect){{margin,0}, size};
    [leftButton setImage:bundleEditImageNamed(@"EditImageTrashBtn.png") forState:UIControlStateNormal];
    [leftButton setImage:bundleEditImageNamed(@"EditImageTrashBtn_HL.png") forState:UIControlStateHighlighted];
    [leftButton setImage:bundleEditImageNamed(@"EditImageTrashBtn_HL.png") forState:UIControlStateSelected];
    [leftButton addTarget:self action:@selector(audioTrackTrash) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:leftButton];
    
    /** 右 */
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = (CGRect){{CGRectGetWidth(self.frame)-size.width-margin,0}, size};
    [rightButton setImage:bundleEditImageNamed(@"EditImageAddBtn.png") forState:UIControlStateNormal];
    [rightButton setImage:bundleEditImageNamed(@"EditImageAddBtn_HL.png") forState:UIControlStateHighlighted];
    [rightButton setImage:bundleEditImageNamed(@"EditImageAddBtn_HL.png") forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(audioTrackAdd) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:rightButton];
    
    [self addSubview:toolbar];
}


#pragma mark - 顶部栏(action)
- (void)cancelButtonClick
{
    if ([self.delegate respondsToSelector:@selector(lf_audioTrackBarDidCancel:)]) {
        [self.delegate lf_audioTrackBarDidCancel:self];
    }
}

- (void)finishButtonClick
{
    BOOL hasOrignal = NO;
    for (NSInteger i=0; i<self.m_select_audioUrls.count; i++) {
        LFAudioItem *item = self.m_select_audioUrls[i];
        if (item.isOriginal) {
            hasOrignal = YES;
        }
    }
    BOOL isError = self.m_select_audioUrls.count > (hasOrignal ? 2 : 1);
    if (isError) {
        _error = [NSError errorWithDomain:NSOSStatusErrorDomain code:-300 userInfo:@{NSLocalizedDescriptionKey:@"最多只能选择1个额外音轨"}];
    }
    if ([self.delegate respondsToSelector:@selector(lf_audioTrackBar:didFinishAudioUrls:)]) {
        [self.delegate lf_audioTrackBar:self didFinishAudioUrls:self.m_select_audioUrls];
    }
    _error = nil;
}

- (void)audioTrackTrash
{
    for (LFAudioItem *item in self.m_select_audioUrls) {
        if (item.isOriginal) {
            continue;
        }
        [self.m_audioUrls removeObject:item];
    }
    if (self.m_select_audioUrls.count) {
        [self.m_select_audioUrls removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)audioTrackAdd
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    picker.prompt = @"请选择需要的歌曲";   //弹出选择播放歌曲的提示
    picker.showsCloudItems = YES;     //显示为下载的歌曲
    picker.allowsPickingMultipleItems = YES;  //是否允许多选
    picker.delegate = self;
    [self.delegate presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    LFAudioItem *item = self.m_audioUrls[indexPath.row];
    [self.m_select_audioUrls addObject:item];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    LFAudioItem *item = self.m_audioUrls[indexPath.row];
    [self.m_select_audioUrls removeObject:item];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_audioUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *audioTrackCellIdentifier = @"audioTrackCellIdentifier";
    
    LFAudioTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:audioTrackCellIdentifier];
    if (cell == nil) {
        cell = [[LFAudioTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioTrackCellIdentifier];
    }
    LFAudioItem *item = self.m_audioUrls[indexPath.row];
    cell.textLabel.text = item.title;
    
    if ([self.m_select_audioUrls containsObject:item]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSMutableArray *mediaUrls = [@[] mutableCopy];
    for (MPMediaItem* mediaItem in [mediaItemCollection items]) {
        NSURL *url = mediaItem.assetURL;
        if (url && [mediaUrls containsObject:url] == NO) {
            [mediaUrls addObject:url];
            LFAudioItem *item = [LFAudioItem new];
            item.title = mediaItem.title;
            item.url = url;
            [self.m_audioUrls addObject:item];
        }
    }
    
    if (mediaUrls.count) {
        [self.tableView reloadData];
    }
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter/setter
- (NSArray<NSURL *> *)audioUrls
{
    return [self.m_audioUrls copy];
}

- (void)setAudioUrls:(NSArray<LFAudioItem *> *)audioUrls
{
    self.m_audioUrls = [@[] mutableCopy];
    if (audioUrls.count) {
        [self.m_audioUrls addObjectsFromArray:audioUrls];
    }
}

@end
