//
//  NSFLanguageModelAndCompareModelTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLanguageModelAndCompareModelTransformer.h"
#import "NSFStringsLanguageModel.h"
#import "NSFStringsSideCompareModel.h"

@implementation NSFLanguageModelAndCompareModelTransformer

+ (NSArray<NSFStringsCompareModel *> *)compareModelsFrom:(NSArray<NSFStringsLanguageModel *> *)languageModels
{
    NSArray<NSArray<NSFStringsLanguageModel *> *> *compoundLanguageModels = [self compoundLineModelsCompatibleWithStoryboardsAndXibs:languageModels];
    
    NSArray *result = [compoundLanguageModels.rac_sequence map:^id(NSArray<NSFStringsLanguageModel *> *array) {
        NSFStringsSideCompareModel *compareModel = [NSFStringsSideCompareModel new];
        [array enumerateObjectsUsingBlock:^(NSFStringsLanguageModel *languageModel, NSUInteger idx, BOOL *stop) {
            [compareModel.keys addObject:languageModel.key];
            compareModel.translations = languageModel.translations;
            
            [languageModel.fileURLs enumerateKeysAndObjectsUsingBlock:^(NSNumber *language, NSURL *fileURL, BOOL *stop) {
                compareModel.fileURLs[[self nsf_fileURLKeyWith:languageModel.key language:language]] = fileURL;
            }];
        }];
        
        return compareModel;
    }].array;
    
    return result;
}

+ (NSArray<NSFStringsLanguageModel *> *)languageModelsFrom:(NSArray<NSFStringsCompareModel *> *)compareModels
{
    NSArray<NSFStringsSideCompareModel *> *stringSideCompareModels = (NSArray<NSFStringsSideCompareModel *> *) compareModels;
    
    return [stringSideCompareModels.rac_sequence flattenMap:^__kindof RACSequence *(NSFStringsSideCompareModel *compareModel) {
        NSArray *lanModels = [compareModel.keys.rac_sequence map:^id(NSString *key) {
            NSFStringsLanguageModel *languageModel = [NSFStringsLanguageModel new];
            languageModel.key = key;
            languageModel.translations = compareModel.translations;
            
            [compareModel.fileURLs enumerateKeysAndObjectsUsingBlock:^(NSString *fileURLKey, NSURL *fileURL, BOOL *stop) {
                NSFLanguage language = [self nsf_languageFromFileURLKey:fileURLKey];
                languageModel.fileURLs[@(language)] = fileURL;
            }];
            
            NSAssert(languageModel.fileURLs.count % 3 == 0, @"从strings文件中解析出的每个Key，对应的语言必须是3的整数倍(含高校版)");
            
            return languageModel;
        }].array;
        
        return lanModels.rac_sequence;
    }].array;
}

#pragma mark - Private
/**
 同一个文案可能同时出现在Localizable.strings、xib.strings和storyboard.strings中，而storyboard.strings和xib.strings文件中的key都是自动生成的objectID，因此会出现文案完全一致但key不一样的情况。对语言包而言这只能算是一条翻译，需要进一步把这些compundModels整合到一起
 */
+ (NSArray<NSArray<NSFStringsLanguageModel *> *> *)compoundLineModelsCompatibleWithStoryboardsAndXibs:(NSArray<NSFStringsLanguageModel *> *)languageModels
{
    NSMutableDictionary<NSString *, NSMutableArray *> *dict = [NSMutableDictionary dictionary];
    for (NSFStringsLanguageModel *reduntantableIntermediaModel in languageModels)
    {
        //根据简体中文、繁体中文和英文生成一个UUID来确定两个model是否需要整合起来
        NSString *UUID = [reduntantableIntermediaModel UUID];
        NSMutableArray *array = dict[UUID];
        if (!array)
        {
            array = [NSMutableArray array];
            dict[UUID] = array;
        }
        
        [array addObject:reduntantableIntermediaModel];
    }
    
    return dict.allValues;
}

/**
 工程端最终生成的compareModel里需要记录每个翻译文案是从哪个strings文件来的，用翻译的Key和文案所属语言类型一起作为fileURL的key
 */
+ (NSString *)nsf_fileURLKeyWith:(NSString *)key language:(NSNumber *)language
{
    return [NSString stringWithFormat:@"%@_%@", key, language];
}

+ (NSFLanguage)nsf_languageFromFileURLKey:(NSString *)key
{
    return [[[key componentsSeparatedByString:@"_"] lastObject] integerValue];
}

@end
