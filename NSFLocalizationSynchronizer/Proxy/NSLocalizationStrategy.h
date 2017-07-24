//
//  NSLocalizationStrategy.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFNotificationUserInfo.h"

@interface NSLocalizationStrategy : NSObject

+ (void)updateKeysInLanguagePack;

//严格模式，即完全根据key进行匹配
+ (void)updateStringFilesInProject_strict;

+ (void)updateStringFilesInProject_normal;

+ (NSUInteger)findNonLocalizedStringsInProject;

/**
 检查工程中.strings文件的合法性并尝试修复，比如一行最末少了分号，转义字符没有加\等，内部是调用了plutil来做的检查
 */
+ (void)fixLocalizedStringsError;

+ (void)updateUnifiedStringFilesInProject;

@end
