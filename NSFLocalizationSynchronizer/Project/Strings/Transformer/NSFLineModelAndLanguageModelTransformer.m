//
//  NSFLineModelAndLanguageModelTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLineModelAndLanguageModelTransformer.h"
#import "NSFKeyValueModel.h"
#import "NSFStringsReduntantableIntermediaModel.h"

@implementation NSFLineModelAndLanguageModelTransformer

+ (NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModelsFrom:(NSArray<NSFKeyValueModel *> *)lineModels
{
    //先将所有行数据整合成key -> zh-Hans、zh-Hant、en的格式
    NSMutableDictionary<NSString *, NSFStringsReduntantableIntermediaModel *> *dict = [NSMutableDictionary dictionary];
    for (NSFKeyValueModel *lineModel in lineModels)
    {
        //不同的.strings文件中可能存在key相同，但表征不同意义的键值对
        //比如多个target的infoPlist.strings文件中可能都有CFBundleDisplayName
        //因此这里将文件路径【去掉/language.proj/.strings部分要相同】也作为uniquekey的一部分
        NSString *prefixPath = [[[lineModel.file absoluteString] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        NSString *uniqueKey = [NSString stringWithFormat:@"%@_%@", lineModel.key, prefixPath];
        NSFStringsReduntantableIntermediaModel *model = dict[uniqueKey];
        if (!model)
        {
            model = [NSFStringsReduntantableIntermediaModel new];
            model.key = lineModel.key;
            dict[uniqueKey] = model;
        }
        
        [model integrate:lineModel];
    }
    
    return dict.allValues;
}

+ (NSArray<NSFKeyValueModel *> *)lineModelsFrom:(NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModels
{
    return [languageModels.rac_sequence flattenMap:^RACStream *(NSFStringsReduntantableIntermediaModel *languageModel) {
        NSFKeyValueModel *zhHans = [NSFKeyValueModel modelAtFile:languageModel.fileURLs[ZH_HANS]
                                                           order:NSNotFound
                                                             key:languageModel.key
                                                           value:languageModel.zh_Hans
                                                        language:ZH_HANS];
        
        NSFKeyValueModel *zhHant = [NSFKeyValueModel modelAtFile:languageModel.fileURLs[ZH_HANT]
                                                           order:NSNotFound
                                                             key:languageModel.key
                                                           value:languageModel.zh_Hant
                                                        language:ZH_HANT];
        
        NSFKeyValueModel *en = [NSFKeyValueModel modelAtFile:languageModel.fileURLs[EN]
                                                       order:NSNotFound
                                                         key:languageModel.key
                                                       value:languageModel.en
                                                    language:EN];
        
        return @[zhHans, zhHant, en].rac_sequence;
    }].array;
}

@end
