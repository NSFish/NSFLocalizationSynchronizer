//
//  NSFCommonTypes.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFCommonTypes.h"

@implementation NSFCommonTypes

+ (NSString *)humanReadableString4:(NSFLanguage)language
{
    NSString *string = nil;
    
    switch (language) {
        case NSFLanguageSimplifiedChinese:
        {
            string = @"简体中文";
        }
            break;
        case NSFLanguageTraditionalChinese:
        {
            string = @"繁体中文";
        }
            break;
        case NSFLanguageEnglish:
        {
            string = @"英文";
        }
            break;
        case NSFLanguageSchoolizedSimplifiedChinese:
        {
            string = @"高校版简体中文";
        }
            break;
        case NSFLanguageSchoolizedTraditionalChinese:
        {
            string = @"高校版繁体中文";
        }
            break;
        case NSFLanguageSchoolizedEnglish:
        {
            string = @"高校版英文";
        }
            break;
        default:
            break;
    }
    
    return string;
}

@end
