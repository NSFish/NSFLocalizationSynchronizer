//
//  NSLocalizationStrategy.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFNotificationUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFLocalizationProxy: NSObject

+ (void)updateKeysInLanguagePack;

//严格模式，即完全根据key进行匹配
+ (void)updateStringFilesInProject_strict;

+ (void)updateStringFilesInProject_normal;

+ (void)updateUnifiedStringFilesInProject;

+ (NSUInteger)findNonLocalizedStringsInProject;

@end

NS_ASSUME_NONNULL_END
