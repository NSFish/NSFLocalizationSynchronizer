//
//  NSFSetting.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFSetting.h"

static NSString *NSFProjectRootFolderPathKey = @"NSFProjectRootFolderPathKey";
static NSString *NSFLanguageFilePathKey = @"NSFLanguageFilePathKey";
static NSString *NSFOutputDirectoryPathKey = @"NSFOutputDirectoryPathKey";

@implementation NSFSetting

+ (NSString *)projectRootFolderPath
{
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:NSFProjectRootFolderPathKey];
    return path ? path : @"";
}

+ (void)setProjectRootFolderPath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:NSFProjectRootFolderPathKey];
}

+ (NSString *)languageFilePath
{
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:NSFLanguageFilePathKey];
    return path ? path : @"";
}

+ (void)setLanguageFilePath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:NSFLanguageFilePathKey];
}

+ (NSString *)outputDirectoryPath
{
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:NSFOutputDirectoryPathKey];
    return path ? path : [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
}

+ (void)setOutputDirectoryPath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:NSFOutputDirectoryPathKey];
}

+ (NSURL *)logFolder
{
    NSString *mainFolder = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSURL *URL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:mainFolder] stringByAppendingPathComponent:@"Log"]];
    [[NSFileManager defaultManager] createDirectoryAtPath:[URL path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    return URL;
}

@end
