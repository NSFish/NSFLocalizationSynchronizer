//
//  AppDelegate.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "AppDelegate.h"
#import "NSFSettingWindowController.h"
#import "NSFLocalizationProxy.h"

@interface AppDelegate()<NSUserNotificationCenterDelegate>
@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSFSettingWindowController *settingWC;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupStatusItem];
}

- (void)setupStatusItem
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:-2];
    self.statusItem.button.image = [NSImage imageNamed:@"StatusItem-Image"];
    
    NSMenu *menu = [NSMenu new];
    [menu addItemWithTitle:@"设置" action:@selector(openSettingWC) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"扫描工程中未国际化的字符串" action:@selector(scanUnlocalizedStringInSourceCode) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"更新文案到工程中【严格】" action:@selector(strictlyUpdateStringFiles) keyEquivalent:@""];
    [menu addItemWithTitle:@"更新文案到工程中【兼容】" action:@selector(updateStringFiles) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"【大一统】更新文案到工程中【严格】" action:@selector(strictlyUpdateUnifiedStringsFiles) keyEquivalent:@""];
    [menu addItemWithTitle:@"【大一统】更新文案到工程中【兼容】" action:@selector(updateUnifiedStringsFiles) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    
    self.statusItem.menu = menu;
}

#pragma mark - Event
- (void)openSettingWC
{
    if (!self.settingWC)
    {
        self.settingWC = [[NSFSettingWindowController alloc] initWithWindowNibName:@"NSFSettingWindowController"];
    }
    [self.settingWC showWindow:nil];
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)scanUnlocalizedStringInSourceCode
{
    [[NSFLocalizationProxy scanUnlocalizedStringInSourceCode] subscribeNext:^(NSArray *unlocalizedStrings) {
        NSUserNotification *userNotification = [NSUserNotification new];
        userNotification.title = @"扫描完毕";
        if (unlocalizedStrings.count == 0)
        {
            userNotification.subtitle = @"所有的字符串都国际化了";
        }
        else
        {
            userNotification.subtitle = [NSString stringWithFormat:@"发现%@条未国际化的字符串，点击查看", @(unlocalizedStrings.count)];
            
            NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/工程中未国际化的字符串.xml"];
            [@{@"count": @(unlocalizedStrings.count),
               @"strings": unlocalizedStrings} nsf_writeToURL:[NSURL fileURLWithPath:logPath]];
            
            userNotification.userInfo = @{@"paths": @[logPath]};
        }
        
        userNotification.soundName = NSUserNotificationDefaultSoundName;
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter deliverNotification:userNotification];
    }];
}

- (void)strictlyUpdateStringFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateStringsFiles:YES] subscribeNext:^(RACTuple *result) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:result strict:YES];
    }];
}

- (void)updateStringFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateStringsFiles:NO] subscribeNext:^(RACTuple *result) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:result strict:NO];
    }];
}

- (void)strictlyUpdateUnifiedStringsFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateUnifiedStringFiles:YES] subscribeNext:^(RACTuple *result) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:result strict:YES];
    }];
}

- (void)updateUnifiedStringsFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateUnifiedStringFiles:NO] subscribeNext:^(RACTuple *result) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:result strict:NO];
    }];
}

#pragma mark - NSUserNotificationCenterDelegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSString *path = notification.userInfo[@"path"];
    [[NSWorkspace sharedWorkspace] openFile:path
                            withApplication:nil
                              andDeactivate:YES];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark - Private
- (void)response2UpdateStringsFiles:(RACTuple *)result strict:(BOOL)strict
{
    NSUInteger updatedCount = [[result first] integerValue];
    NSMutableArray<NSDictionary *> *mismatchedStringModels = [result second];
    
    NSString *xmlPath = nil;
    if (mismatchedStringModels.count > 0)
    {
        NSString *mode = strict ? @"严格模式" : @"兼容模式";
        xmlPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Desktop/【%@】更新失败的文案.xml", mode]];
        [@{@"count": @(mismatchedStringModels.count),
           @"Models": mismatchedStringModels} nsf_writeToURL:[NSURL fileURLWithPath:xmlPath]];
    }
    
    NSUserNotification *userNotification = [NSUserNotification new];
    userNotification.title = [NSString stringWithFormat:@"更新了%@条文案", @(updatedCount)];
    
    if (xmlPath)
    {
        userNotification.informativeText = @"发现工程中存在语言包里没有的文案，点击查看";
        userNotification.userInfo = @{@"path": xmlPath};
    }
    
    userNotification.soundName = NSUserNotificationDefaultSoundName;
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter deliverNotification:userNotification];
}

@end
