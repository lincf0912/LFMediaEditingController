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

+ (instancetype)defaultAudioItem
{
    LFAudioItem *item = [self new];
    if (item) {
        item.title = [NSBundle LFME_localizedStringForKey:@"_LFME_defaultAudioItem_name"];
        item.isEnable = YES;
    }
    return item;
}

- (BOOL)isOriginal
{
    return self.title == [NSBundle LFME_localizedStringForKey:@"_LFME_defaultAudioItem_name"] && self.url == nil;
}

@end


@interface LFAudioTrackCell : UITableViewCell

@end

@implementation LFAudioTrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.multipleSelectionBackgroundView = [[UIView alloc] init];
    }
    return self;
}



@end

@interface LFAudioTrackBar () <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray <NSMutableArray <LFAudioItem *> *> *m_audioUrls;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *allSelectButton;
@property (nonatomic, weak) UIButton *inverseSelectButton;

@property (nonatomic, strong) UIImage *selectCacheImage;
@property (nonatomic, strong) UIImage *noSelectCacheImage;


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
        _naviHeight = 44.f;
        if (layoutBlock) {
            layoutBlock(self);
        }
        layoutBlock = nil;
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.f];
    _m_audioUrls = [@[] mutableCopy];
    _selectCacheImage = bundleAudioTrackImageNamed(@"EditImageSelectd.png");
    _noSelectCacheImage = bundleAudioTrackImageNamed(@"EditImageNoSelect.png");
    
    [self configCustomNaviBar];
    [self configTableView];
    [self configToolbar];
}

- (void)configCustomNaviBar
{
    /** 顶部栏 */
    CGFloat margin = 8;
    CGFloat size = _naviHeight;
    UIView *topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, _customTopbarHeight)];
    topbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    topbar.backgroundColor = [UIColor clearColor];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat editCancelWidth = [self.cancelButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, size) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, topbar.height-size, editCancelWidth, size)];
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = font;
    [cancelButton setTitleColor:self.cancelButtonTitleColorNormal forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat editOkWidth = [self.oKButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, size) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width + 30;
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - editOkWidth - margin, topbar.height-size, editOkWidth, size)];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
#pragma clang diagnostic pop
    /** 解决ios7中tableview每一行下面的线向右偏移的问题 */
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if (@available(iOS 11.0, *)){
        [tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    
//    tableView.editing = YES;
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (void)configToolbar
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-_customToolbarHeight, self.width, _customToolbarHeight)];
    
    CGFloat rgb = 34 / 255.0;
    toolbar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    CGSize size = CGSizeMake(44, 44);
    CGFloat margin = 10.f;
    
    CGFloat marginX = margin;
    /** 左 */
    UIButton *allSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allSelectButton.frame = (CGRect){{marginX,0}, size};
    [allSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageAllSelect.png") forState:UIControlStateNormal];
    [allSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageAllSelect_HL.png") forState:UIControlStateHighlighted];
    [allSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageUnSelect.png") forState:UIControlStateSelected];
    [allSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageUnSelect_HL.png") forState:UIControlStateSelected|UIControlStateHighlighted];
    [allSelectButton addTarget:self action:@selector(audioTrackAllSelect:) forControlEvents:UIControlEventTouchUpInside];
    allSelectButton.enabled = NO;
    [toolbar addSubview:allSelectButton];
    _allSelectButton = allSelectButton;
    marginX += CGRectGetMaxX(allSelectButton.frame) + margin;
    
    UIButton *inverseSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inverseSelectButton.frame = (CGRect){{marginX,0}, size};
    [inverseSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageInverseSelect.png") forState:UIControlStateNormal];
    [inverseSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageInverseSelect_HL.png") forState:UIControlStateHighlighted];
    [inverseSelectButton setImage:bundleAudioTrackImageNamed(@"EditImageInverseSelect_HL.png") forState:UIControlStateSelected];
    [inverseSelectButton addTarget:self action:@selector(audioTrackInverseSelect) forControlEvents:UIControlEventTouchUpInside];
    inverseSelectButton.enabled = NO;
    [toolbar addSubview:inverseSelectButton];
    _inverseSelectButton = inverseSelectButton;
    
    /** 右 */
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = (CGRect){{CGRectGetWidth(self.frame)-size.width-margin,0}, size};
    [addButton setImage:bundleAudioTrackImageNamed(@"EditImageAddBtn.png") forState:UIControlStateNormal];
    [addButton setImage:bundleAudioTrackImageNamed(@"EditImageAddBtn_HL.png") forState:UIControlStateHighlighted];
    [addButton setImage:bundleAudioTrackImageNamed(@"EditImageAddBtn_HL.png") forState:UIControlStateSelected];
    [addButton addTarget:self action:@selector(audioTrackAdd) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:addButton];
    
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
    if ([self.delegate respondsToSelector:@selector(lf_audioTrackBar:didFinishAudioUrls:)]) {
        [self.delegate lf_audioTrackBar:self didFinishAudioUrls:self.audioUrls];
    }
}

- (void)audioTrackTrash
{
    NSMutableArray <LFAudioItem *>*deleteItems = [@[] mutableCopy];
    for (NSMutableArray *list in self.m_audioUrls) {
        for (LFAudioItem *item in list) {
            
            if (item.isOriginal) {
                continue;
            }
            if (item.isEnable) {
                [deleteItems addObject:item];
            }
        }
    }
    if (deleteItems.count) {
        for (NSMutableArray *list in self.m_audioUrls) {
            [list removeObjectsInArray:deleteItems];;
        }
        [self.tableView reloadData];
        [self checkAllSelectState];
    }
}

- (void)audioTrackAllSelect:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    for (NSMutableArray *list in self.m_audioUrls) {
        for (LFAudioItem *item in list) {
            if (item.isOriginal) {
                continue;
            }
            item.isEnable = sender.isSelected;
        }
    }
    [self.tableView reloadData];
}

- (void)audioTrackInverseSelect
{
    for (NSMutableArray *list in self.m_audioUrls) {
        for (LFAudioItem *item in list) {
            if (item.isOriginal) {
                continue;
            }
            item.isEnable = !item.isEnable;
        }
    }
    [self.tableView reloadData];
    [self checkAllSelectState];
}

- (void)audioTrackAdd
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    picker.prompt = [NSBundle LFME_localizedStringForKey:@"_LFME_MediaPicker_prompt"];   //弹出选择播放歌曲的提示
    picker.showsCloudItems = YES;     //显示为下载的歌曲
    picker.allowsPickingMultipleItems = YES;  //是否允许多选
    picker.delegate = self;
    [self.delegate presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    NSMutableArray *list = self.m_audioUrls[indexPath.section];
    LFAudioItem *item = list[indexPath.row];
    item.isEnable = !item.isEnable;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self checkAllSelectState];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section > 0) {
        return 44.f;
    }
    return 0.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    view.backgroundColor = self.backgroundColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0, view.frame.size.width-20.f, view.frame.size.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 1.f;
    label.text = [NSBundle LFME_localizedStringForKey:@"_LFME_AudioTackTitle_prompt"];
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    return view;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.m_audioUrls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *list = [self.m_audioUrls objectAtIndex:section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *audioTrackCellIdentifier = @"audioTrackCellIdentifier";
    
    LFAudioTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:audioTrackCellIdentifier];
    if (cell == nil) {
        cell = [[LFAudioTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioTrackCellIdentifier];
    }
    NSMutableArray *list = self.m_audioUrls[indexPath.section];
    LFAudioItem *item = list[indexPath.row];
    cell.textLabel.text = item.title;
    
    if (item.isEnable) {
        [cell.imageView setImage:self.selectCacheImage];
    } else {
        [cell.imageView setImage:self.noSelectCacheImage];
    }
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section > 0) {
//        return [NSBundle LFME_localizedStringForKey:@"_LFME_AudioTackTitle_prompt"];
//    }
//    return nil;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        NSMutableArray *list = self.m_audioUrls[indexPath.section];
        [list removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [self checkAllSelectState];
    }
}

#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSMutableArray *mediaUrls = [@[] mutableCopy];
    NSMutableArray *list = nil;
    if (self.m_audioUrls.count > 1) {
        list = self.m_audioUrls.lastObject;
    } else {
        list = [NSMutableArray array];
        [self.m_audioUrls addObject:list];
    }
    for (MPMediaItem* mediaItem in [mediaItemCollection items]) {
        NSURL *url = mediaItem.assetURL;
        if (url && [mediaUrls containsObject:url] == NO) {
            [mediaUrls addObject:url];
            LFAudioItem *item = [LFAudioItem new];
            item.title = mediaItem.title;
            item.url = url;
            item.isEnable = YES;
            [list addObject:item];
        }
    }
    
    if (mediaUrls.count) {
        [self.tableView reloadData];
        [self checkAllSelectState];
    }
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter/setter
- (NSArray<LFAudioItem *> *)audioUrls
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
    for (NSMutableArray *subList in self.m_audioUrls) {
        [list addObjectsFromArray:subList];
    }
    return [list copy];
}

- (void)setAudioUrls:(NSArray<LFAudioItem *> *)audioUrls
{
    self.m_audioUrls = [@[] mutableCopy];
    
    NSMutableArray *originalList = [NSMutableArray array];
    NSMutableArray *customList = [NSMutableArray array];
    for (LFAudioItem *item in audioUrls) {
        if (item.isOriginal) {
            [originalList addObject:item];
        } else {
            [customList addObject:item];
        }
    }
    if (originalList.count) {
        [self.m_audioUrls addObject:originalList];
    }
    if (customList.count) {
        [self.m_audioUrls addObject:customList];
    }
    [self checkAllSelectState];
}

#pragma mark - resetAllSelectState
- (void)checkAllSelectState
{
    if (self.m_audioUrls.count > 1) {
        _allSelectButton.enabled = YES;
        _inverseSelectButton.enabled = YES;
        
        BOOL allEnabel = YES;
        NSMutableArray *list = self.m_audioUrls.lastObject;
        for (LFAudioItem *item in list) {
            if (!item.isEnable) {
                allEnabel = NO;
                break;
            }
        }
        _allSelectButton.selected = allEnabel;
    } else {
        _allSelectButton.selected = NO;
        _allSelectButton.enabled = NO;
        _inverseSelectButton.enabled = NO;
    }
}

@end
