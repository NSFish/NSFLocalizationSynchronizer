//
//  AppDelegate.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "AppDelegate.h"
#import "NSFSettingWindowController.h"
#import "NSLocalizationStrategy.h"

@interface AppDelegate ()<NSUserNotificationCenterDelegate>

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
    [menu addItemWithTitle:@"同步工程文件到语言包(更新key)" action:@selector(updateLanguageFile) keyEquivalent:@""];
    [menu addItemWithTitle:@"同步语言包到工程文件(更新文案)" action:@selector(updateStringFilesInProject) keyEquivalent:@""];
    [menu addItemWithTitle:@"双向同步(先更新Key，再更新文案)" action:@selector(bidirectionSync) keyEquivalent:@""];
    [menu addItemWithTitle:@"检查工程文件中简体中文文案一致的翻译" action:@selector(findZh_HansEqualTranslations) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    
    self.statusItem.menu = menu;
}

#pragma mark - Action
- (void)openSettingWC
{
    if (!self.settingWC)
    {
        self.settingWC = [[NSFSettingWindowController alloc] initWithWindowNibName:@"NSFSettingWindowController"];
    }
    [self.settingWC showWindow:nil];
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)updateStringFilesInProject
{
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil] take:1] subscribeNext:^(NSNotification *notification) {
        //TODO:如何避免这个警告？
        NSFDidUpdateProjectNotificationUserInfo *userInfo = (NSFDidUpdateProjectNotificationUserInfo *)notification.userInfo;

        NSUserNotification *userNotification = [NSUserNotification new];
        userNotification.title = [NSString stringWithFormat:@"更新了%@条文案", @(userInfo.updateCount)];
        
        if (userInfo.uselessLogFilePath)
        {
            userNotification.informativeText = @"发现工程中存在语言包里没有的文案，点击查看";
            userNotification.userInfo = @{@"path": userInfo.uselessLogFilePath};
        }
        
        userNotification.soundName = NSUserNotificationDefaultSoundName;
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter deliverNotification:userNotification];
    }];
    
    [NSLocalizationStrategy updateStringFilesInProject];
}

- (void)updateLanguageFile
{
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:[NSFDidUpdateLanguageFileNotificationUserInfo notificationName] object:nil] take:1] subscribeNext:^(NSNotification *notification) {
        //TODO:如何避免这个警告？
        NSFDidUpdateLanguageFileNotificationUserInfo *userInfo = (NSFDidUpdateLanguageFileNotificationUserInfo *)notification.userInfo;
        
        NSUserNotification *userNotification = [NSUserNotification new];
        userNotification.title = [NSString stringWithFormat:@"更新了%@个Key", @(userInfo.updateCount)];
        
        if (userInfo.uselessLogFilePath && !userInfo.duplicatedLogFilePath)
        {
            userNotification.informativeText = @"发现语言包中存在无用文案，点击查看";
            userNotification.userInfo = @{@"paths": @[userInfo.uselessLogFilePath]};
        }
        else if (!userInfo.uselessLogFilePath && userInfo.duplicatedLogFilePath)
        {
            userNotification.informativeText = @"发现语言包中存在重复文案，点击查看";
            userNotification.userInfo = @{@"paths": @[userInfo.duplicatedLogFilePath]};
        }
        else if (userInfo.uselessLogFilePath && userInfo.duplicatedLogFilePath)
        {
            userNotification.subtitle = @"发现语言包中存在无用文案，点击查看";
            userNotification.informativeText = @"发现语言包中存在重复文案，点击查看";
            userNotification.userInfo = @{@"paths": @[userInfo.uselessLogFilePath, userInfo.duplicatedLogFilePath]};
        }
        
        userNotification.soundName = NSUserNotificationDefaultSoundName;
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter deliverNotification:userNotification];
    }];

    [NSLocalizationStrategy updateKeysInLanguagePack];
}

- (void)bidirectionSync
{
    
}

- (void)findZh_HansEqualTranslations
{
    [NSLocalizationStrategy findDuplicatedZh_HansTranslations];
}

#pragma mark - NSUserNotificationCenterDelegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSArray<NSString *> *paths = notification.userInfo[@"paths"];
    NSArray<NSURL *> *URLs = [paths.rac_sequence map:^id(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }].array;
    
    if (URLs.count == 1)
    {
        [[NSWorkspace sharedWorkspace] openFile:[paths firstObject]
                                withApplication:nil
                                  andDeactivate:YES];
    }
    else if (URLs.count > 1)
    {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:URLs];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
