//
//  NSLocalizationStrategy.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLocalizationProxy.h"
#import "NSFSetting.h"
#import "NSFLanguagePackageExpert.h"
#import <XMLDictionary.h>
#import "NSFSourceCodeScanner.h"
#import "NSFProjectExpert.h"
#import "NSFStringsCompareModel.h"

@implementation NSFLocalizationProxy

+ (void)updateKeysInLanguagePack
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
        NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
        
        NSFProjectExpert *stringsExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRootFolderURL];
        NSArray<NSFStringsCompareModel *> *modelsFromStrings = [stringsExpert compareModels:NO];
        
        NSFLanguagePackageExpert *excelFileHandler = [NSFLanguagePackageExpert load:languageFileURL];
        NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler compareModels];
        
        //遍历语言包生成的中间数据，更新Key
        //记录找不到对应key的文案
        NSMutableArray *notUsedModelsFromExcel = [NSMutableArray array];
        //记录更新key的文案数
        NSUInteger updatedCount = 0;
        
        for (NSFLanguagePackLineModel *languagePackModel in modelsFromExcel)
        {
            //暴力对比所有的文案，三种语言的文案全部一致的，即为工程中对应的key
            NSFStringsCompareModel *stringModel = [[modelsFromStrings.rac_sequence filter:^BOOL(NSFStringsCompareModel *model) {
                return [model.zh_Hans isEqualToString:languagePackModel.zh_Hans]
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
        NSFLanguagePackageExpert *newLaunguageFileHandler = [NSFLanguagePackageExpert create:newLanguageFileURL];
        [newLaunguageFileHandler updateCompareModels:modelsFromExcel];
        
        NSFDidUpdateLanguageFileNotificationUserInfo *userInfo = [NSFDidUpdateLanguageFileNotificationUserInfo userInfoWithUpdateCount:updatedCount uselessLogFilePath:uselessLogFilePath duplicatedLogFilePath:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateLanguageFileNotificationUserInfo notificationName] object:nil userInfo:userInfo];
    });
}

+ (void)updateStringFilesInProject_strict
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
        NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
        
        NSFProjectExpert *stringsExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRootFolderURL];
        NSArray<NSFStringsCompareModel *> *modelsFromStrings = [stringsExpert compareModels:NO];
        
        NSFLanguagePackageExpert *excelFileHandler = [NSFLanguagePackageExpert load:languageFileURL];
        NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler compareModels];
        
        //记录更新了的文案条数
        NSUInteger updatedTranslationsCount = 0;
        
        //遍历.strings文件生成的中间数据
        //更新在语言包中匹配得到的文案
        //输出匹配不到的文案的xml
        NSMutableArray *mismatchedStringModels = [NSMutableArray array];
        
        for (NSFStringsCompareModel *stringModel in modelsFromStrings)
        {
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
        [stringsExpert updateCompareModels:modelsFromStrings];
        
        NSString *xmlPath = nil;
        if (mismatchedStringModels.count > 0)
        {
            NSDictionary *xmlDict = @{@"count": @(mismatchedStringModels.count).stringValue, @"model": mismatchedStringModels};
            xmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/【严格】excel中不存在key的文案.xml"];
            [self writeDictionary:xmlDict toPath:xmlPath];
        }
        
        NSFDidUpdateProjectNotificationUserInfo *userInfo = [NSFDidUpdateProjectNotificationUserInfo userInfoWithUpdateCount:updatedTranslationsCount
                                                                                                          uselessLogFilePath:xmlPath
                                                                                                        multipleMatchXmlPath:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil userInfo:userInfo];
    });
}

+ (void)updateStringFilesInProject_normal
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
        NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
        
        NSFProjectExpert *stringsExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRootFolderURL];
        NSArray<NSFStringsCompareModel *> *modelsFromStrings = [stringsExpert compareModels:NO];
        
        NSFLanguagePackageExpert *excelFileHandler = [NSFLanguagePackageExpert load:languageFileURL];
        NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler compareModels];
        
        //记录更新了的文案条数
        NSUInteger updatedTranslationsCount = 0;
        
        //兼容模式下才匹配到的文案【key匹配不到，通过简体中文翻译匹配到了超过一个的翻译】
        NSMutableArray<NSDictionary *> *multipleMatchedStringModels = [NSMutableArray array];
        
        //遍历.strings文件生成的中间数据
        //更新在语言包中匹配得到的文案
        //输出匹配不到的文案的xml
        NSMutableArray<NSDictionary *> *mismatchedStringModels = [NSMutableArray array];
        
        for (NSFStringsCompareModel *stringModel in modelsFromStrings)
        {
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
                //在兼容模式下直接用简体中文来查找excel中的对应model，以查找到的第一个为准
                NSArray<NSFLanguagePackLineModel *> *languageModels = [modelsFromExcel.rac_sequence filter:^BOOL(NSFLanguagePackLineModel *model) {
                    return [stringModel.zh_Hans isEqualToString:model.zh_Hans];
                }].array;
                
                if (languageModels.count == 1)//只找到一行匹配到的翻译，就是它了
                {
                    NSFLanguagePackLineModel *languagePackModel = [languageModels firstObject];
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
                else if (languageModels.count > 1)
                {
                    [multipleMatchedStringModels addObject:[stringModel toDictionary]];
                }
                else//仍然找不到，记录为冗余文案
                {
                    [mismatchedStringModels addObject:[stringModel toDictionary]];
                }
            }
        }
        
        //将更新文案写回到工程中
        [stringsExpert updateCompareModels:modelsFromStrings];
        
        NSString *mismatchXmlPath = nil;
        if (mismatchedStringModels.count > 0)
        {
            NSDictionary *xmlDict = @{@"count": @(mismatchedStringModels.count).stringValue, @"model": mismatchedStringModels};
            mismatchXmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/【兼容】工程文件中的冗余文案.xml"];
            [self writeDictionary:xmlDict toPath:mismatchXmlPath];
        }
        
        NSString *multipleMatchXmlPath = nil;
        if (multipleMatchXmlPath)
        {
            NSDictionary *xmlDict = @{@"count": @(multipleMatchedStringModels.count).stringValue, @"model": multipleMatchedStringModels};
            multipleMatchXmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/【兼容】在Excel中不止一条匹配翻译的文案.xml"];
            [self writeDictionary:xmlDict toPath:multipleMatchXmlPath];
        }
        
        NSFDidUpdateProjectNotificationUserInfo *userInfo = [NSFDidUpdateProjectNotificationUserInfo userInfoWithUpdateCount:updatedTranslationsCount
                                                                                                          uselessLogFilePath:mismatchXmlPath
                                                                                                        multipleMatchXmlPath:multipleMatchXmlPath];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil userInfo:userInfo];
    });
}

+ (NSUInteger)findNonLocalizedStringsInProject
{
    NSURL *projectRoot = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
    NSFProjectExpert *expert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRoot];
    NSArray<NSFSourceCodeFragment *> *fragments = [expert scanUnlocalizedStringInSourceCode];
    
    if (fragments.count > 0)
    {
        NSArray<NSDictionary *> *nonLocalizedStrings = [fragments.rac_sequence map:^id(NSFSourceCodeFragment *fragment) {
            return [fragment toDictionary];
        }].array;
        
        NSDictionary *xmlDict = @{@"count": @(fragments.count).stringValue, @"strings": nonLocalizedStrings};
        NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/工程中未国际化的字符串.xml"];
        [self writeDictionary:xmlDict toPath:logPath];
    }
    
    return fragments.count;
}

+ (void)updateUnifiedStringFilesInProject
{
    NSURL *projectRootFolderURL = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
    NSFProjectExpert *stringsExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRootFolderURL];
    NSArray<NSFStringsCompareModel *> *modelsFromStrings = [stringsExpert compareModels:YES];
        
    NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
    NSFLanguagePackageExpert *excelFileHandler = [NSFLanguagePackageExpert load:languageFileURL];
    NSArray<NSFLanguagePackLineModel *> *modelsFromExcel = [excelFileHandler compareModels];
    
    //记录更新了的文案条数
    NSUInteger updatedTranslationsCount = 0;
    
    //兼容模式下才匹配到的文案【key匹配不到，通过简体中文翻译匹配到了超过一个的翻译】
    NSMutableArray<NSDictionary *> *multipleMatchedStringModels = [NSMutableArray array];
    
    //遍历.strings文件生成的中间数据
    //更新在语言包中匹配得到的文案
    //输出匹配不到的文案的xml
    NSMutableArray<NSDictionary *> *mismatchedStringModels = [NSMutableArray array];
    
    for (NSFStringsCompareModel *stringModel in modelsFromStrings)
    {
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
            //在兼容模式下直接用简体中文来查找excel中的对应model，以查找到的第一个为准
            NSArray<NSFLanguagePackLineModel *> *languageModels = [modelsFromExcel.rac_sequence filter:^BOOL(NSFLanguagePackLineModel *model) {
                return [stringModel.zh_Hans isEqualToString:model.zh_Hans];
            }].array;
            
            if (languageModels.count == 1)//只找到一行匹配到的翻译，就是它了
            {
                NSFLanguagePackLineModel *languagePackModel = [languageModels firstObject];
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
            else if (languageModels.count > 1)
            {
                [multipleMatchedStringModels addObject:[stringModel toDictionary]];
            }
            else//仍然找不到，记录为冗余文案
            {
                [mismatchedStringModels addObject:[stringModel toDictionary]];
            }
        }
    }
    
    //将更新文案写回到工程中
    [stringsExpert updateCompareModels:modelsFromStrings];
    
    NSString *mismatchXmlPath = nil;
    if (mismatchedStringModels.count > 0)
    {
        NSDictionary *xmlDict = @{@"count": @(mismatchedStringModels.count).stringValue, @"model": mismatchedStringModels};
        mismatchXmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/【兼容】工程文件中的冗余文案.xml"];
        [self writeDictionary:xmlDict toPath:mismatchXmlPath];
    }
    
    NSString *multipleMatchXmlPath = nil;
    if (multipleMatchXmlPath)
    {
        NSDictionary *xmlDict = @{@"count": @(multipleMatchedStringModels.count).stringValue, @"model": multipleMatchedStringModels};
        multipleMatchXmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Desktop/【兼容】在Excel中不止一条匹配翻译的文案.xml"];
        [self writeDictionary:xmlDict toPath:multipleMatchXmlPath];
    }
    
    NSFDidUpdateProjectNotificationUserInfo *userInfo = [NSFDidUpdateProjectNotificationUserInfo userInfoWithUpdateCount:updatedTranslationsCount
                                                                                                      uselessLogFilePath:mismatchXmlPath
                                                                                                    multipleMatchXmlPath:multipleMatchXmlPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSFDidUpdateProjectNotificationUserInfo notificationName] object:nil userInfo:userInfo];
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
