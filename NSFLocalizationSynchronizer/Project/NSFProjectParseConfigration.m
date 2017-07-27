//
//  NSFProjectParseConfigration.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/21.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFProjectParseConfigration.h"

NSString * const NSFMainStringFileName = @"Localizable.strings";

@implementation NSFProjectParseConfigration

+ (NSURL *)projectZh_HansLprojURLIn:(NSURL *)projectRoot
{
    return [[projectRoot URLByAppendingPathComponent:@"CoolOffice"]
            URLByAppendingPathComponent:@"zh-Hans.lproj"];
}

+ (NSURL *)projectZh_HantLprojURLIn:(NSURL *)projectRoot
{
    return [[projectRoot URLByAppendingPathComponent:@"CoolOffice"]
            URLByAppendingPathComponent:@"zh-Hant.lproj"];
}

+ (NSURL *)projectENLprojURLIn:(NSURL *)projectRoot
{
    return [[projectRoot URLByAppendingPathComponent:@"CoolOffice"]
            URLByAppendingPathComponent:@"en.lproj"];
}

+ (NSURL *)tempZh_HansLprojURL
{
    NSURL *URL = [[self tempFolder] URLByAppendingPathComponent:@"zh-Hans.lproj"];
    [[NSFileManager defaultManager] createDirectoryAtPath:[URL path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    return URL;
}

+ (NSURL *)tempZh_HantLprojURL
{
    NSURL *URL = [[self tempFolder] URLByAppendingPathComponent:@"zh-Hant.lproj"];
    [[NSFileManager defaultManager] createDirectoryAtPath:[URL path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    return URL;
}

+ (NSURL *)tempENLprojURL
{
    NSURL *URL = [[self tempFolder] URLByAppendingPathComponent:@"en.lproj"];
    [[NSFileManager defaultManager] createDirectoryAtPath:[URL path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    return URL;
}

+ (NSURL *)tempFolder
{
    NSString *mainFolder = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:mainFolder];
}

@end
