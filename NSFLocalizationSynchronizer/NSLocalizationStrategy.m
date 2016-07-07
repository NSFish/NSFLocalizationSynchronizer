//
//  NSLocalizationStrategy.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSLocalizationStrategy.h"
#import "NSFSetting.h"
#import "YFYLocalizedStrinsFileHandler.h"
#import "YFYLocalizedExcelFileHandler.h"
#import "NSString+LineInStringsFile.h"
#import <XMLDictionary.h>

@implementation NSLocalizationStrategy

+ (void)updateKeysInLanguagePack
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
        NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
        
        YFYLocalizedStrinsFileHandler *stringsFileHandler = [[YFYLocalizedStrinsFileHandler alloc] initWithProjectRootDirectory:projectRootFolderURL];
        NSArray<NSFStringsIntermediaModel *> *modelsFromStrings = [stringsFileHandler intermediaModels];
        
        YFYLocalizedExcelFileHandler *excelFileHandler = [YFYLocalizedExcelFileHandler load:languageFileURL];
        NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler intermediaModels];
        
        //遍历语言包生成的中间数据，更新Key
        //记录找不到对应key的文案
        NSMutableArray *notUsedModelsFromExcel = [NSMutableArray array];
        //记录更新key的文案数
        NSUInteger updatedCount = 0;
        
        for (NSFLanguagePackLineModel *languagePackModel in modelsFromExcel)
        {
            //暴力对比所有的文案，三种语言的文案全部一致的，即为工程中对应的key
            NSFStringsIntermediaModel *stringModel = [[modelsFromStrings.rac_sequence filter:^BOOL(NSFStringsIntermediaModel *model) {
                return [[model.zh_Hans precomposedStringWithCanonicalMapping] isEqualToString:languagePackModel.zh_Hans]
                        && [model.zh_Hant isEqualToString:languagePackModel.zh_Hant]
                        && [model.en isEqualToString:languagePackModel.en];
            }].array firstObject];
            
            if (stringModel)//找到了工程中的对应翻译，更新key
            {
                if (![stringModel.keys containsObject:languagePackModel.key])
                {
                    languagePackModel.key = [stringModel.keys firstObject];
                    updatedCount++;
                }
                
                if (![languagePackModel.platform containsString:@"iOS"])//如果之前未指定平台，需要指定一下
                {
                    languagePackModel.platform = languagePackModel.platform ? [NSString stringWithFormat:@"iOS %@", languagePackModel.platform] : @"iOS";
                }
            }
            else
            {
                if (![languagePackModel.platform.lowercaseString containsString:@"android"])
                {
                    [notUsedModelsFromExcel addObject:[languagePackModel toDictionary]];
                }
            }
        }
        
        NSString *uselessLogFilePath = nil;
        if (notUsedModelsFromExcel.count > 0)
        {
            NSDictionary *xmlDict = @{@"count": @(notUsedModelsFromExcel.count), @"model": notUsedModelsFromExcel};
            uselessLogFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/语言包中没有被用到的文案.xml"];
            [self writeDictionary:xmlDict toPath:uselessLogFilePath];
        }
        
        //重新生成excel
        NSURL *newLanguageFileURL = [NSURL fileURLWithPath:@"/Users/lexingyu/Desktop/App语言包.xlsx"];
        YFYLocalizedExcelFileHandler *newLaunguageFileHandler = [YFYLocalizedExcelFileHandler create:newLanguageFileURL];
        [newLaunguageFileHandler writeToFile:modelsFromExcel];
        
        NSFDidUpdateLanguageFileNotificationUserInfo *userInfo = [NSFDidUpdateLanguageFileNotificationUserInfo userInfoWithUpdateCount:updatedCount uselessLogFilePath:uselessLogFilePath duplicatedLogFilePath:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateLanguageFileNotificationUserInfo notificationName] object:nil userInfo:userInfo];
    });
}

+ (void)updateStringFilesInProject
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
        NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
        
        YFYLocalizedStrinsFileHandler *stringsFileHandler = [[YFYLocalizedStrinsFileHandler alloc] initWithProjectRootDirectory:projectRootFolderURL];
        NSArray<NSFStringsIntermediaModel *> *modelsFromStrings = [stringsFileHandler intermediaModels];
        
        YFYLocalizedExcelFileHandler *excelFileHandler = [YFYLocalizedExcelFileHandler load:languageFileURL];
        NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler intermediaModels];
        
        //记录更新了的文案条数
        NSUInteger updatedTranslationsCount = 0;
        
        //遍历.strings文件生成的中间数据
        //更新在语言包中匹配得到的文案
        //输出匹配不到的文案的xml
        NSMutableArray *mismatchedStringModels = [NSMutableArray array];
        
        for (NSFStringsIntermediaModel *stringModel in modelsFromStrings)
        {
            if ([stringModel.keys.rac_sequence any:^BOOL(NSString *key) {
                return [key containsString:@"_dropMenu"];
            }])
            {
                continue;
            }
            
            //找到语言包中key相同的那一行翻译
            NSFLanguagePackLineModel *languagePackModel = [[modelsFromExcel.rac_sequence filter:^BOOL(NSFLanguagePackLineModel *model) {
                return [stringModel.keys containsObject:model.key];
            }].array firstObject];
            
            if (languagePackModel)
            {
                if (![stringModel.zh_Hans isEqualToString:languagePackModel.zh_Hans]
                    || ![stringModel.zh_Hant isEqualToString:languagePackModel.zh_Hant]
                    || ![stringModel.en isEqualToString:languagePackModel.en])
                {
                    stringModel.zh_Hans = languagePackModel.zh_Hans;
                    stringModel.zh_Hant = languagePackModel.zh_Hant;
                    stringModel.en = languagePackModel.en;
                    
                    updatedTranslationsCount++;
                }
            }
            else
            {
                //找不到的话，可能是因为该行翻译还没有key，或者这个文案在语言包里没有，记录下来
                [mismatchedStringModels addObject:[stringModel toDictionary]];
            }
        }
        
        //将更新文案写回到工程中
        [stringsFileHandler overrideStringFiles:modelsFromStrings];
        
        NSString *xmlPath = nil;
        if (mismatchedStringModels.count > 0)
        {
            NSDictionary *xmlDict = @{@"count": @(mismatchedStringModels.count).stringValue, @"model": mismatchedStringModels};
            xmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/工程文件中的冗余文案.xml"];
            [self writeDictionary:xmlDict toPath:xmlPath];
        }
        
        NSFDidUpdateProjectNotificationUserInfo *userInfo = [NSFDidUpdateProjectNotificationUserInfo userInfoWithUpdateCount:updatedTranslationsCount uselessLogFilePath:xmlPath];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil userInfo:userInfo];
    });
}

+ (void)findDuplicatedZh_HansTranslations
{
    //    NSURL *URL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
    //    YFYLocalizedStrinsFileHandler *stringsHandler = [[YFYLocalizedStrinsFileHandler alloc] initWithProjectRootDirectory:URL];
    //
    //    NSDictionary *modelsFromStrings = [stringsHandler generalModels];
    //
    //    NSMutableDictionary *sortedModels = [NSMutableDictionary dictionary];
    //    for (NSDictionary *stringDict in modelsFromStrings.allValues)
    //    {
    //        NSString *zh_Hans = stringDict[@"zh-Hans"];
    //        if (!zh_Hans)
    //        {
    //            continue;
    //        }
    //
    //        NSMutableArray *array = sortedModels[zh_Hans];
    //        if (!array)
    //        {
    //            array = [NSMutableArray array];
    //            sortedModels[zh_Hans] = array;
    //        }
    //
    //        [array addObject:stringDict];
    //    }
    //
    //    NSMutableDictionary *mutableSortModels = [sortedModels mutableCopy];
    //    for (NSString *key in sortedModels.allKeys)
    //    {
    //        NSMutableArray *array = sortedModels[key];
    //        if (array.count == 1)
    //        {
    //            [mutableSortModels removeObjectForKey:key];
    //        }
    //    }
    //
    //    [self writeDictionary:@{@"model": mutableSortModels.allValues} toPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/工程文件中简体中文重复的文案.xml"]];
}

#pragma mark - Private
+ (void)writeDictionary:(NSDictionary *)dictionary toPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:[dictionary XMLString] options:0 error:nil];
    NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    [xmlData writeToFile:path atomically:YES];
}


@end
