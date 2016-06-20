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

+ (void)updateStringFilesInProject;
+ (void)updateKeysInLanguagePack;

+ (void)findDuplicatedZh_HansTranslations;

@end
