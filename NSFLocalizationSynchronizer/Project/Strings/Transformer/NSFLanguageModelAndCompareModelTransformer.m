//
//  NSFLanguageModelAndCompareModelTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLanguageModelAndCompareModelTransformer.h"
#import "NSFStringsReduntantableIntermediaModel.h"
#import "NSFStringsSideCompareModel.h"

@implementation NSFLanguageModelAndCompareModelTransformer

+ (NSArray<NSFStringsIntermediaModel *> *)compareModelsFrom:(NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModels
{
    NSArray<NSArray<NSFStringsReduntantableIntermediaModel *> *> *compoundLanguageModels = [self compoundLineModelsCompatibleWithStoryboardsAndXibs:languageModels];
    
    NSArray *result = [compoundLanguageModels.rac_sequence map:^id(NSArray<NSFStringsReduntantableIntermediaModel *> *array) {
        NSFStringsSideCompareModel *compareModel = [NSFStringsSideCompareModel new];
        [array enumerateObjectsUsingBlock:^(NSFStringsReduntantableIntermediaModel *languageModel, NSUInteger idx, BOOL *stop) {
            [compareModel.keys addObject:languageModel.key];
            compareModel.zh_Hans = languageModel.zh_Hans;
            compareModel.zh_Hant = languageModel.zh_Hant;
            compareModel.en = languageModel.en;
            
            [languageModel.fileURLs enumerateKeysAndObjectsUsingBlock:^(NSString *language, NSURL *fileURL, BOOL *stop) {
                compareModel.fileURLs[[self fileURLKeyWith:languageModel.key language:language]] = fileURL;
            }];
        }];
        
        return compareModel;
    }].array;
    
    return result;
}

+ (NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModelsFrom:(NSArray<NSFStringsIntermediaModel *> *)compareModels
{
    NSArray<NSFStringsSideCompareModel *> *stringSideCompareModels = (NSArray<NSFStringsSideCompareModel *> *) compareModels;
    return [stringSideCompareModels.rac_sequence flattenMap:^RACStream *(NSFStringsSideCompareModel *compareModel) {
        NSArray *lanModels = [compareModel.keys.rac_sequence map:^id(NSString *key) {
            NSFStringsReduntantableIntermediaModel *languageModel = [NSFStringsReduntantableIntermediaModel new];
            languageModel.key = key;
            languageModel.zh_Hans = compareModel.zh_Hans;
            languageModel.zh_Hant = compareModel.zh_Hant;
            languageModel.en = compareModel.en;
            
            languageModel.fileURLs[ZH_HANS] = compareModel.fileURLs[[self fileURLKeyWith:key language:ZH_HANS]];
            languageModel.fileURLs[ZH_HANT] = compareModel.fileURLs[[self fileURLKeyWith:key language:ZH_HANT]];
            languageModel.fileURLs[EN] = compareModel.fileURLs[[self fileURLKeyWith:key language:EN]];
            
            if (languageModel.fileURLs.count != 3)
            {
                NSLog(@"language model = %@", languageModel);
            }
            
            return languageModel;
        }].array;
        
        return lanModels.rac_sequence;
    }].array;
}

#pragma mark - Private
/**
 同一个文案可能同时出现在Localizable.strings、xib.strings和storyboard.strings中，而storyboard.strings和xib.strings文件中的key都是自动生成的objectID，因此会出现文案完全一致但key不一样的情况。对语言包而言这只能算是一条翻译，需要进一步把这些compundModels整合到一起
 */
+ (NSArray<NSArray<NSFStringsReduntantableIntermediaModel *> *> *)compoundLineModelsCompatibleWithStoryboardsAndXibs:(NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModels
{
    NSMutableDictionary<NSString *, NSMutableArray *> *dict = [NSMutableDictionary dictionary];
    for (NSFStringsReduntantableIntermediaModel *reduntantableIntermediaModel in languageModels)
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

+ (NSString *)fileURLKeyWith:(NSString *)key language:(NSString *)language
{
    return [NSString stringWithFormat:@"%@_%@", key, language];
}

@end
