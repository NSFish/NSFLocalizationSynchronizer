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
#import "NSFSourceCodeScanner.h"
#import "NSFProjectExpert.h"
#import "NSFStringsCompareModel.h"
#import "NSFLogger.h"

@implementation NSFLocalizationProxy

#pragma mark - 语言包
+ (RACSignal<NSArray<NSURL *> *> *)scanLanguagePack
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
            NSFLanguagePackageExpert *expert = [NSFLanguagePackageExpert load:languageFileURL];
            
            NSMutableArray<NSURL *> *logs = [NSMutableArray array];
            NSURL *log = [NSFLogger logIfNeeded:[expert scanKeyDuplicatedRows] withName:@"语言包中重复的Key"];
            [logs nsf_addObjectIfNotNil:log];
            
            log = [NSFLogger logIfNeeded:[expert scanTranslationDuplicatedRows] withName:@"语言包中重复的翻译"];;
            [logs nsf_addObjectIfNotNil:log];
            
            log = [NSFLogger logIfNeeded:[expert scanZh_HansDuplicatedOnlyRows] withName:@"语言包中简体中文相同但其他翻译不同的行"];
            [logs nsf_addObjectIfNotNil:log];
            
            [subscriber sendNext:logs];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

#pragma mark - Project
+ (RACSignal *)scanUnlocalizedStringInSourceCode
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *projectRoot = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
            NSFProjectExpert *expert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRoot];
            NSArray<NSFSourceCodeFragment *> *fragments = [expert scanUnlocalizedStringInSourceCode];
            
            NSArray<NSDictionary *> *unlocalizedStrings = [fragments.rac_sequence map:^id(NSFSourceCodeFragment *fragment) {
                return [fragment toDictionary];
            }].array;
            
            [subscriber sendNext:[NSFLogger logIfNeeded:unlocalizedStrings withName:@"工程中未国际化的字符串"]];
            
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

#pragma mark - 同步
+ (RACSignal *)updateStringsFiles:(BOOL)strict
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *projectRoot = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
            NSFProjectExpert *projectExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRoot];
            NSArray<NSFStringsCompareModel *> *stringsModels = [projectExpert compareModels:NO];
            
            NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
            NSFLanguagePackageExpert *languagePackExpert = [NSFLanguagePackageExpert load:languageFileURL];
            NSArray<NSFLanguagePackLineModel *> *languagePackModels = [languagePackExpert compareModels];
            
            NSArray<NSDictionary *> *result = nil;
            if (strict)
            {
                result = [self p_strictlyCompareStringsModels:stringsModels withLanguagePackModels:languagePackModels];
            }
            else
            {
                result = [self p_compareStringsModels:stringsModels withLanguagePackModels:languagePackModels];
            }
            [projectExpert updateCompareModels:stringsModels];
            
            NSString *mode = strict ? @"严格" : @"兼容";
            [subscriber sendNext:[NSFLogger logIfNeeded:result
                                               withName:[NSString stringWithFormat:@"【%@】工程中用到了语言包中不存在的文案", mode]]];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

+ (RACSignal *)updateUnifiedStringFiles:(BOOL)strict
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *projectRoot = [NSURL fileURLWithPath:[NSFSetting projectRootFolderPath]];
            NSFProjectExpert *projectExpert = [[NSFProjectExpert alloc] initWithProjectRoot:projectRoot];
            NSArray<NSFStringsCompareModel *> *stringsModels = [projectExpert compareModels:YES];
            
            NSURL *languageFileURL = [NSURL fileURLWithPath:[NSFSetting languageFilePath]];
            NSFLanguagePackageExpert *languagePackExpert = [NSFLanguagePackageExpert load:languageFileURL];
            NSArray<NSFLanguagePackLineModel *> *languagePackModels = [languagePackExpert compareModels];
            
            NSArray<NSDictionary *> *result = nil;
            if (strict)
            {
                result = [self p_strictlyCompareStringsModels:stringsModels withLanguagePackModels:languagePackModels];
            }
            else
            {
                result = [self p_compareStringsModels:stringsModels withLanguagePackModels:languagePackModels];
            }
            [projectExpert updateCompareModels:stringsModels];
            
            NSString *mode = strict ? @"严格" : @"兼容";
            [subscriber sendNext:[NSFLogger logIfNeeded:result
                                               withName:[NSString stringWithFormat:@"【%@】工程中用到了语言包中不存在的文案", mode]]];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

#pragma mark - Private(同步)
+ (NSArray<NSDictionary *> *)p_strictlyCompareStringsModels:(NSArray<NSFStringsCompareModel *> *)stringsModels
                                     withLanguagePackModels:(NSArray<NSFLanguagePackLineModel *> *)languagePackModels
{
    NSMutableArray<NSDictionary *> *mismatchedStringModels = [NSMutableArray array];
    
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *strictLanguageModels = [NSMutableDictionary dictionary];
    [languagePackModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSMutableArray *strictLineModels = strictLanguageModels[lineModel.key];
        if (!strictLineModels)
        {
            strictLanguageModels[lineModel.key] = [@[lineModel] mutableCopy];
        }
        else
        {
            [strictLineModels addObject:lineModel];
        }
    }];
    
    for (NSFStringsCompareModel *stringModel in stringsModels)
    {
        //找到语言包中key相同的那一行翻译
        NSFLanguagePackLineModel *languagePackModel = [self p_strictlyFindLanguageModelMatch:stringModel
                                                                                      from:strictLanguageModels];
        
        if (languagePackModel)
        {
            stringModel.translations = languagePackModel.translations;
        }
        else
        {
            //找不到的话，可能是因为该行翻译还没有key，或者这个文案在语言包里没有，记录下来
            [mismatchedStringModels addObject:[stringModel toDictionary]];
        }
    }
    
    return mismatchedStringModels;
}

+ (NSArray<NSDictionary *> *)p_compareStringsModels:(NSArray<NSFStringsCompareModel *> *)stringsModels
                             withLanguagePackModels:(NSArray<NSFLanguagePackLineModel *> *)languagePackModels
{
    NSMutableArray<NSDictionary *> *mismatchedStringModels = [NSMutableArray array];
    
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *strictLanguageModels = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *normalLanguageModels = [NSMutableDictionary dictionary];
    [languagePackModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSMutableArray *strictLineModels = strictLanguageModels[lineModel.key];
        if (!strictLineModels)
        {
            strictLanguageModels[lineModel.key] = [@[lineModel] mutableCopy];
        }
        else
        {
            [strictLineModels addObject:lineModel];
        }
        
        NSString *simplifiedChinese = [lineModel translation4Language:NSFLanguageSimplifiedChinese];
        NSMutableArray *normalLineModels = normalLanguageModels[simplifiedChinese];
        if (!normalLineModels)
        {
            normalLanguageModels[simplifiedChinese] = [@[lineModel] mutableCopy];
        }
        else
        {
            [normalLineModels addObject:lineModel];
        }
    }];
    
    for (NSFStringsCompareModel *stringModel in stringsModels)
    {
        NSFLanguagePackLineModel *languagePackModel = [self p_strictlyFindLanguageModelMatch:stringModel
                                                                                      from:strictLanguageModels];
        if (!languagePackModel)
        {
            //找不到的话，可能是因为该行翻译还没有key，或者这个文案在语言包里没有，记录下来
            //在兼容模式下直接用简体中文来查找excel中的对应model，以查找到的第一个为准
            languagePackModel = [self p_findLanguageModelMatch:stringModel from:normalLanguageModels];
        }
        
        if (languagePackModel)
        {
            stringModel.translations = languagePackModel.translations;
        }
        else
        {
            //找不到的话，可能是因为该行翻译还没有key，或者这个文案在语言包里没有，记录下来
            [mismatchedStringModels addObject:[stringModel toDictionary]];
        }
    }
    
    return mismatchedStringModels;
}

+ (NSFLanguagePackLineModel *)p_strictlyFindLanguageModelMatch:(NSFStringsCompareModel *)stringsModel
                                                          from:(NSDictionary<NSString *, NSArray<NSFLanguagePackLineModel *> *> *)languageModels
{
    //找到语言包中key相同的那一行翻译
    __block NSFLanguagePackLineModel *languagePackModel = nil;
    [stringsModel.keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSArray<NSFLanguagePackLineModel *> *lineModels = languageModels[key];
        if (lineModels)
        {
            languagePackModel = [lineModels firstObject];
            *stop = YES;
        }
    }];
    
    return languagePackModel;
}

+ (NSFLanguagePackLineModel *)p_findLanguageModelMatch:(NSFStringsCompareModel *)stringsModel
                                                  from:(NSDictionary<NSString *, NSArray<NSFLanguagePackLineModel *> *> *)languageModels
{
    NSString *simplifiedChinese = [stringsModel translation4Language:NSFLanguageSimplifiedChinese];
    NSArray<NSFLanguagePackLineModel *> *lineModels = languageModels[simplifiedChinese];
    if (lineModels.count == 1)//只找到一行匹配到的翻译，就是它了
    {
        return [lineModels firstObject];
    }
    
    return nil;
}

@end
