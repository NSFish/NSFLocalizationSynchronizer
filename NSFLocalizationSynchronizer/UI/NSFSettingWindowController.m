//
//  NSFSettingWindowController.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFSettingWindowController.h"
#import "NSFSetting.h"

@interface NSFSettingWindowController ()
@property (weak) IBOutlet NSTextField *projectRootFolderPathTextField;
@property (weak) IBOutlet NSTextField *languageFilePathTextField;
@property (weak) IBOutlet NSTextField *outputDirectoryTextField;

@end


@implementation NSFSettingWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.projectRootFolderPathTextField.stringValue = [NSFSetting projectRootFolderPath];
    self.languageFilePathTextField.stringValue = [NSFSetting languageFilePath];
    self.outputDirectoryTextField.stringValue = [NSFSetting outputDirectoryPath];
}

- (IBAction)selectProjectRootFolder:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[[openPanel URLs] firstObject] path];
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]
                && isDirectory)
            {
                self.projectRootFolderPathTextField.stringValue = path;
                [NSFSetting setProjectRootFolderPath:path];
            }
        }
    }];
}

- (IBAction)selectLanguageFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[[openPanel URLs] firstObject] path];
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]
                && !isDirectory)
            {
                self.languageFilePathTextField.stringValue = path;
                [NSFSetting setLanguageFilePath:path];
            }
        }
    }];
}

- (IBAction)selectOutputDirectory:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[[openPanel URLs] firstObject] path];
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]
                && isDirectory)
            {
                self.outputDirectoryTextField.stringValue = path;
                [NSFSetting setOutputDirectoryPath:path];
            }
        }
    }];
}


@end
