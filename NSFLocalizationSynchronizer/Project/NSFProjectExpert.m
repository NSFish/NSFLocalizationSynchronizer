//
//  NSFLocalizedStrinsExpert.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/11.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFProjectExpert.h"
#import "NSFKeyValueModel.h"
#import "NSFStringsLanguageModel.h"
#import "NSFStringsCompareModel.h"
#import "NSFTransformerUmbrella.h"
#import "NSFProjectParseConfigration.h"
#import "NSFSourceCodeScanner.h"

@interface NSFProjectExpert()
@property (nonatomic, copy) NSURL *projectRoot;

/**
 暂存lineModels，以保证写回.strings文件时每行位置不变
 */
@property (nonatomic, strong) NSArray<NSFStringsLineModel *> *lineModels;

@end


@implementation NSFProjectExpert

- (instancetype)initWithProjectRoot:(NSURL *)projectRoot
{
    if (self = [super init])
    {
        self.projectRoot = projectRoot;
    }
    
    return self;
}

- (NSArray<NSFSourceCodeFragment *> *)scanUnlocalizedStringInSourceCode
{
    return [NSFSourceCodeScanner findNonLocalizedStringsIn:self.projectRoot];
}

#pragma mark - Compare
- (NSArray<NSFStringsCompareModel *> *)compareModels:(BOOL)unified
{
    NSArray<NSURL *> *stringFiles = unified ? [self unifiedStringFiles] : [self stringFiles];
    
    self.lineModels = [stringFiles.rac_sequence flattenMap:^RACStream *(NSURL *fileURL) {
        return [NSFStringsFileAndLineModelTransformer lineModelsFrom:fileURL].rac_sequence;
    }].array;
    
    //只取包含键值对的行
    NSArray<NSFKeyValueModel *> *keyValueModels = [self.lineModels.rac_sequence filter:^BOOL(id value) {
        return [value isKindOfClass:[NSFKeyValueModel class]];
    }].array;
    
    return [NSFLanguageModelAndCompareModelTransformer compareModelsFrom:
            [NSFLineModelAndLanguageModelTransformer languageModelsFrom:keyValueModels]];
}

- (void)updateCompareModels:(NSArray<NSFStringsCompareModel *> *)compareModels
{
    NSArray<NSFKeyValueModel *> *comparedLineModels = [NSFLineModelAndLanguageModelTransformer lineModelsFrom:[NSFLanguageModelAndCompareModelTransformer languageModelsFrom:compareModels]];
    
    [self calculateLineModelOrders:comparedLineModels];
    
    //把空白行和注释行加回来
    NSMutableArray<__kindof NSFStringsLineModel *> *lineModels = [NSMutableArray arrayWithArray:comparedLineModels];
    [self.lineModels enumerateObjectsUsingBlock:^(NSFStringsLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        if (![lineModel isKindOfClass:[NSFKeyValueModel class]])
        {
            [lineModels addObject:lineModel];
        }
    }];
    self.lineModels = nil;
    
    //将更新过的lineModels按文件分组，逐批写回
    NSMutableDictionary<NSURL *, NSMutableArray<__kindof NSFStringsLineModel *> *> *dict = [NSMutableDictionary dictionary];
    for (NSFStringsLineModel *model in lineModels)
    {
        NSMutableArray<__kindof NSFStringsLineModel *> *array = nil;
        if ([dict.allKeys containsObject:model.file])
        {
            array = dict[model.file];
        }
        else
        {
            array = [NSMutableArray array];
            dict[model.file] = array;
        }
        
        [array addObject:model];
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSURL *fileURL, NSMutableArray<__kindof NSFStringsLineModel *> *lineModels, BOOL *stop) {
        NSString *content = [NSFStringsFileAndLineModelTransformer stringsFileContentFrom:lineModels];
        [content writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

- (void)calculateLineModelOrders:(NSArray<NSFKeyValueModel *> *)comparedLineModels
{
    //预处理之前保留下来的lineModels，使self.lineModels和comparedLineModels都只需要循环一遍，提高性能
    NSMutableDictionary<NSString *, NSFKeyValueModel *> *dict = [NSMutableDictionary dictionary];
    [self.lineModels enumerateObjectsUsingBlock:^(NSFStringsLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSFKeyValueModel *keyValueModel = [NSFKeyValueModel safelyCast:lineModel];
        if (keyValueModel)
        {
            dict[keyValueModel.UUID] = keyValueModel;
        }
    }];
    
    [comparedLineModels enumerateObjectsUsingBlock:^(NSFKeyValueModel *comparedLineModel, NSUInteger idx, BOOL *stop) {
        NSFKeyValueModel *matchedLineModel = dict[comparedLineModel.UUID];
        if (matchedLineModel)//如果lineModel已经存在，获取其在string文件中原本的位置
        {
            comparedLineModel.order = matchedLineModel.order;
        }
        else
        {
            //由于strings文件本身是由本App生成的，各种翻译都应该是齐全的，因此不可能出现
            //新增lineModel的情况
        }
    }];
}

#pragma mark - Private
- (NSArray<NSURL *> *)stringFiles
{
    return [NSFStringFilesMixTransformer regenerateAllStringFilesIn:self.projectRoot];
}

- (NSArray<NSURL *> *)unifiedStringFiles
{
    NSString *content = [NSFStringFilesMixTransformer mixedStringFileContentFrom:self.projectRoot];
    NSURL *zh_hans = [[[NSFProjectParseConfigration tempZh_HansLprojURL]
                       URLByAppendingPathComponent:NSFMainStringFileName]
                      URLByAppendingPathExtension:@"strings"];
    NSURL *zh_hant = [[[NSFProjectParseConfigration tempZh_HantLprojURL]
                       URLByAppendingPathComponent:NSFMainStringFileName]
                      URLByAppendingPathExtension:@"strings"];
    NSURL *en = [[[NSFProjectParseConfigration tempENLprojURL]
                  URLByAppendingPathComponent:NSFMainStringFileName]
                 URLByAppendingPathExtension:@"strings"];
    [content writeToURL:zh_hans atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [content writeToURL:zh_hant atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [content writeToURL:en atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return @[zh_hans, zh_hant, en];
}

@end
