//
//  NSFLineModelAndLanguageModelTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLineModelAndLanguageModelTransformer.h"
#import "NSFKeyValueModel.h"
#import "NSFStringsLanguageModel.h"

@implementation NSFLineModelAndLanguageModelTransformer

+ (NSArray<NSFStringsLanguageModel *> *)languageModelsFrom:(NSArray<NSFKeyValueModel *> *)lineModels
{
    //先将所有行数据整合成key -> zh-Hans、zh-Hant、en的格式
    NSMutableDictionary<NSString *, NSFStringsLanguageModel *> *dict = [NSMutableDictionary dictionary];
    for (NSFKeyValueModel *lineModel in lineModels)
    {
        //不同的.strings文件中可能存在key相同，但表征不同意义的键值对
        //比如多个target的infoPlist.strings文件中可能都有CFBundleDisplayName
        //因此这里将文件路径【去掉/language.proj/.strings部分要相同】也作为uniquekey的一部分
        NSString *prefixPath = [[[lineModel.file absoluteString] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        NSString *fileName = [[lineModel.file lastPathComponent] stringByReplacingOccurrencesOfString:@"school_" withString:@""];
        NSString *uniqueKey = [NSString stringWithFormat:@"%@_%@_%@", lineModel.key, prefixPath, fileName];
        NSFStringsLanguageModel *model = dict[uniqueKey];
        if (!model)
        {
            model = [NSFStringsLanguageModel new];
            model.key = lineModel.key;
            dict[uniqueKey] = model;
        }
        
        [model integrate:lineModel];
    }
    
    return dict.allValues;
}

+ (NSArray<NSFKeyValueModel *> *)lineModelsFrom:(NSArray<NSFStringsLanguageModel *> *)languageModels
{
    return [languageModels.rac_sequence flattenMap:^__kindof RACSequence *(NSFStringsLanguageModel *languageModel) {
        NSMutableArray<NSFKeyValueModel *> *lineModels = [NSMutableArray array];
        
        [languageModel.translations enumerateKeysAndObjectsUsingBlock:^(NSNumber *language, NSString *obj, BOOL *stop) {
            NSFKeyValueModel *lineModel = [NSFKeyValueModel modelAtFile:languageModel.fileURLs[language]
                                                                  order:NSNotFound
                                                                    key:languageModel.key
                                                                  value:obj
                                                               language:language.integerValue];
            
            //某些从语言包中生成的行在工程中没有对应的lineModel是合理的
            //比如Info.plist是不生成高校版.strings文件的，因此就不会有对应的lineModel
            //这些lineModel简单地抛弃掉即可
            if (lineModel.file)
            {
                [lineModels addObject:lineModel];
            }
        }];
        
        return lineModels.rac_sequence;
    }].array;
}

@end
