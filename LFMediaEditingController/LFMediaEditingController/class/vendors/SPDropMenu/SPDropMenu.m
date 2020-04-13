//
//  SPDropMenu.m
//  DropDownMenu
//
//  Created by TsanFeng Lam on 2019/8/29.
//  Copyright © 2019 SampleProjectsBooth. All rights reserved.
//

#import "SPDropMenu.h"
#import "SPDropMainMenu.h"

static SPDropMainMenu *_SPDropMainMenu;

const NSString *SPDropMainMenu_autoDismiss = @"SPDropMainMenu_autoDismiss";
const NSString *SPDropMainMenu_backgroundColor = @"SPDropMainMenu_backgroundColor";
const NSString *SPDropMainMenu_direction = @"SPDropMainMenu_direction";

static NSMutableDictionary *_SPDrapMainMenuPropertys;

@implementation SPDropMenu

#pragma mark - preporty
+ (void)setAutoDismiss:(BOOL)isAutoDismiss
{
    self.SPDrapMainMenuPropertys[SPDropMainMenu_autoDismiss] = @(isAutoDismiss);
    _SPDropMainMenu.autoDismiss = isAutoDismiss;
}

+ (BOOL)isOnShow
{
    return (BOOL)_SPDropMainMenu;
}

+ (void)setBackgroundColor:(UIColor *)color
{
    self.SPDrapMainMenuPropertys[SPDropMainMenu_backgroundColor] = color;
    _SPDropMainMenu.containerViewbackgroundColor = color;
}
+ (void)setDirection:(SPDropMainMenuDirection)direction
{
    self.SPDrapMainMenuPropertys[SPDropMainMenu_direction] = @(direction);
}

#pragma mark - function
+ (void)showInView:(UIView *)view items:(NSArray <id <SPDropItemProtocol>>*)items
{
    [self dismissWithAnimated:NO];
    _SPDropMainMenu = [self SPDropMainMenuWithItems:items];
    [_SPDropMainMenu showInView:view];
}
+ (void)showFromPoint:(CGPoint)point items:(NSArray <id <SPDropItemProtocol>>*)items
{
    [self dismissWithAnimated:NO];
    _SPDropMainMenu = [self SPDropMainMenuWithItems:items];
    [_SPDropMainMenu showFromPoint:point];
}

+ (void)dismiss
{
    [self dismissWithAnimated:YES];
}

+ (void)dismissWithAnimated:(BOOL)animated
{
    if (_SPDropMainMenu) {
        [_SPDropMainMenu dismissWithAnimated:animated];
        _SPDropMainMenu = nil;
    }
}

#pragma mark - private
+ (NSMutableDictionary *)SPDrapMainMenuPropertys
{
    if (_SPDrapMainMenuPropertys == nil) {
        _SPDrapMainMenuPropertys = [NSMutableDictionary dictionary];
    }
    return _SPDrapMainMenuPropertys;
}

+ (SPDropMainMenu *)SPDropMainMenuWithItems:(NSArray <id <SPDropItemProtocol>>*)items
{
    SPDropMainMenu *dropMainMenu = [[SPDropMainMenu alloc] init];
    dropMainMenu.displayMaxNum = 0;
    id value = self.SPDrapMainMenuPropertys[SPDropMainMenu_autoDismiss];
    if (value) {
        dropMainMenu.autoDismiss = [value boolValue];
    }
    value = self.SPDrapMainMenuPropertys[SPDropMainMenu_backgroundColor];
    if (value) {
        dropMainMenu.containerViewbackgroundColor = value;
    }
    value = self.SPDrapMainMenuPropertys[SPDropMainMenu_direction];
    if (value) {
        dropMainMenu.direction = [value integerValue];
    }
    for (id <SPDropItemProtocol> item in items) {
        [dropMainMenu addItem:item];
    }
    return dropMainMenu;
}

@end
