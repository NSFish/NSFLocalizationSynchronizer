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
        self.settingWC = [[NSFSettingWindowController alloc] initWithWindowNibName:NSStringFromClass([NSFSettingWindowController class])];
    }
    [self.settingWC showWindow:nil];
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)scanUnlocalizedStringInSourceCode
{
    [[NSFLocalizationProxy scanUnlocalizedStringInSourceCode] subscribeNext:^(NSURL *log) {
        NSUserNotification *userNotification = [NSUserNotification new];
        userNotification.title = @"扫描完毕";
        if (!log)
        {
            userNotification.subtitle = @"所有的字符串都国际化了";
        }
        else
        {
            userNotification.subtitle = @"发现未国际化的字符串，点击查看";
            userNotification.userInfo = @{@"path": [log path]};
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
    [[NSFLocalizationProxy updateStringsFiles:YES] subscribeNext:^(NSURL *log) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:log strict:YES];
    }];
}

- (void)updateStringFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateStringsFiles:NO] subscribeNext:^(NSURL *log) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:log strict:NO];
    }];
}

- (void)strictlyUpdateUnifiedStringsFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateUnifiedStringFiles:YES] subscribeNext:^(NSURL *log) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:log strict:YES];
    }];
}

- (void)updateUnifiedStringsFiles
{
    @weakify(self);
    [[NSFLocalizationProxy updateUnifiedStringFiles:NO] subscribeNext:^(NSURL *log) {
        @strongify(self);
        
        [self response2UpdateStringsFiles:log strict:NO];
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
- (void)response2UpdateStringsFiles:(NSURL *)log strict:(BOOL)strict
{
    NSUserNotification *userNotification = [NSUserNotification new];
    
    if (log)
    {
        userNotification.informativeText = @"发现工程中存在语言包里没有的文案，点击查看";
        userNotification.userInfo = @{@"path": [log path]};
    }
    
    userNotification.soundName = NSUserNotificationDefaultSoundName;
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter deliverNotification:userNotification];
}

@end
