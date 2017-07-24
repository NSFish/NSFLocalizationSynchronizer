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
#import "NSFSourceCodeScanner.h"

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

    [menu addItemWithTitle:@"扫描工程中未国际化的字符串" action:@selector(findNonLocalizedStringsInProject) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItemWithTitle:@"【大一统】更新文案到工程中【严格】" action:@selector(updateUnifiedStringFilesInProject) keyEquivalent:@""];
    [menu addItemWithTitle:@"【大一统】更新文案到工程中【兼容】" action:@selector(updateUnifiedStringFilesInProject) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"更新文案到工程中【严格】" action:@selector(updateStringFilesInProject_strict) keyEquivalent:@""];
    [menu addItemWithTitle:@"更新文案到工程中【兼容】" action:@selector(updateStringFilesInProject_normal) keyEquivalent:@""];
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

- (void)findNonLocalizedStringsInProject
{
    NSUInteger nonLocalizedStringsCount = [NSLocalizationStrategy findNonLocalizedStringsInProject];
    
    NSUserNotification *userNotification = [NSUserNotification new];
    userNotification.title = @"扫描完毕";
    if (nonLocalizedStringsCount == 0)
    {
        userNotification.subtitle = @"所有的字符串都国际化了";
    }
    else
    {
        userNotification.subtitle = [NSString stringWithFormat:@"发现%@条未国际化的字符串，点击查看", @(nonLocalizedStringsCount)];
        NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/工程中未国际化的字符串.xml"];
        userNotification.userInfo = @{@"paths": @[logPath]};
    }
    
    userNotification.soundName = NSUserNotificationDefaultSoundName;
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter deliverNotification:userNotification];
}

- (void)updateUnifiedStringFilesInProject
{
    [NSLocalizationStrategy updateUnifiedStringFilesInProject];
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

- (void)updateStringFilesInProject_strict
{
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil] take:1] subscribeNext:^(NSNotification *notification) {
        //TODO:如何避免这个警告？
        NSFDidUpdateProjectNotificationUserInfo *userInfo = (NSFDidUpdateProjectNotificationUserInfo *)notification.userInfo;
        
        NSUserNotification *userNotification = [NSUserNotification new];
        userNotification.title = [NSString stringWithFormat:@"更新了%@条文案", @(userInfo.updateCount)];
        
        if (userInfo.multipleMatchXmlPath)
        {
            userNotification.informativeText = @"工程中文案在语言包中存在多个匹配项，点击查看";
            userNotification.userInfo = @{@"path": userInfo.multipleMatchXmlPath};
        }
        else if (userInfo.uselessLogFilePath)
        {
            userNotification.informativeText = @"工程中存在语言包里没有的文案，点击查看";
            userNotification.userInfo = @{@"path": userInfo.uselessLogFilePath};
        }
        
        userNotification.soundName = NSUserNotificationDefaultSoundName;
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter deliverNotification:userNotification];
    }];
    
    [NSLocalizationStrategy updateStringFilesInProject_strict];
}

- (void)updateStringFilesInProject_normal
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
    
    [NSLocalizationStrategy updateStringFilesInProject_normal];
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
