//
//  NSFCommonTypes.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define HumanReadable(language) [NSFCommonTypes humanReadableString4:language]

typedef NS_ENUM(NSUInteger, NSFLanguage)
{
    NSFLanguageSimplifiedChinese,
    NSFLanguageTraditionalChinese,
    NSFLanguageEnglish,
    NSFLanguageSchoolizedSimplifiedChinese,
    NSFLanguageSchoolizedTraditionalChinese,
    NSFLanguageSchoolizedEnglish
};

@interface NSFCommonTypes: NSObject

+ (NSString *)humanReadableString4:(NSFLanguage)language;

@end

NS_ASSUME_NONNULL_END
