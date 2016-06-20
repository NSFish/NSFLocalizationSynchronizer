//
//  NSFNotificationUserInfo.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/14.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFNotificationUserInfo.h"

@interface NSFDidUpdateProjectNotificationUserInfo()
@property (nonatomic, assign) NSUInteger updateCount;
@property (nonatomic, copy)   NSString   *uselessLogFilePath;

@end

@implementation NSFDidUpdateProjectNotificationUserInfo

+ (NSString *)notificationName
{
    return @"NSFDidUpdateProjectNotification";
}

+ (instancetype)userInfoWithUpdateCount:(NSUInteger)updateCount
                     uselessLogFilePath:(NSString *)uselessLogFilePath
{
    NSFDidUpdateProjectNotificationUserInfo *userInfo = [NSFDidUpdateProjectNotificationUserInfo new];
    userInfo.updateCount = updateCount;
    userInfo.uselessLogFilePath = uselessLogFilePath;
    
    return userInfo;
}

@end


@interface NSFDidUpdateLanguageFileNotificationUserInfo()
@property (nonatomic, assign) NSUInteger updateCount;
@property (nonatomic, copy)   NSString   *uselessLogFilePath;
@property (nonatomic, copy)   NSString   *duplicatedLogFilePath;

@end


@implementation NSFDidUpdateLanguageFileNotificationUserInfo

+ (NSString *)notificationName
{
    return @"NSFDidUpdateLanguageFileNotification";
}

+ (instancetype)userInfoWithUpdateCount:(NSUInteger)updateCount
                     uselessLogFilePath:(NSString *)uselessLogFilePath
                  duplicatedLogFilePath:(NSString *)duplicatedLogFilePath
{
    NSFDidUpdateLanguageFileNotificationUserInfo *userInfo = [NSFDidUpdateLanguageFileNotificationUserInfo new];
    userInfo.updateCount = updateCount;
    userInfo.uselessLogFilePath = uselessLogFilePath;
    userInfo.duplicatedLogFilePath = duplicatedLogFilePath;
    
    return userInfo;
}

@end
