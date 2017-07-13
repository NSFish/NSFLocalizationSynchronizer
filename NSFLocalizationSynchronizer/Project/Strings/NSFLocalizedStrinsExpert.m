//
//  NSFLocalizedStrinsExpert.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/11.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLocalizedStrinsExpert.h"
#import "NSFKeyValueModel.h"
#import "NSFStringsReduntantableIntermediaModel.h"
#import "NSFStringsIntermediaModel.h"
#import "NSFTransformerUmbrella.h"

@interface NSFLocalizedStrinsExpert()
@property (nonatomic, copy) NSURL *projectRoot;

/**
 暂存lineModels，以保证写回.strings文件时每行位置不变
 */
@property (nonatomic, strong) NSArray<NSFStringsLineModel *> *lineModels;

@end


@implementation NSFLocalizedStrinsExpert

- (instancetype)initWithProjectRoot:(NSURL *)projectRoot
{
    if (self = [super init])
    {
        self.projectRoot = projectRoot;
    }
    
    return self;
}

#pragma mark - Public
- (NSArray<NSURL *> *)stringFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:self.projectRoot
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             return YES;
                                         }];
    
    NSMutableArray *fileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator)
    {
        NSString *filename = nil;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if ([isDirectory boolValue])
        {
            if ([filename hasPrefix:@"Pods"]
                || [filename isEqualToString:@"Carthage"]
                || [filename isEqualToString:@"Base.lproj"]
                || [filename containsString:@"Test"])
            {
                [enumerator skipDescendants];
            }
            
            continue;
        }
        else
        {
            if ([filename hasSuffix:@".strings"]
                && ![[filename stringByDeletingPathExtension] isEqualToString:@"imageName"])
            {
                [fileURLs addObject:fileURL];
            }
        }
    }
    
    return [fileURLs.rac_sequence filter:^BOOL(NSURL *fileURL) {
        return ![[fileURL path] containsString:@"school"];
    }].array;
}

- (NSArray<NSFStringsIntermediaModel *> *)compareModels
{
    NSArray<NSURL *> *stringFiles = [self stringFiles];
    
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

- (void)updateCompareModels:(NSArray<NSFStringsIntermediaModel *> *)compareModels
{
    NSArray<NSFKeyValueModel *> *comparedLineModels = [NSFLineModelAndLanguageModelTransformer lineModelsFrom:[NSFLanguageModelAndCompareModelTransformer languageModelsFrom:compareModels]];
    
    __block NSUInteger newLine = self.lineModels.count;
    [comparedLineModels enumerateObjectsUsingBlock:^(NSFKeyValueModel *comparedLineModel, NSUInteger idx, BOOL *stop) {
        NSFKeyValueModel *matchedLineModel = [[self.lineModels.rac_sequence filter:^BOOL(NSFKeyValueModel *lineModel) {
            return [lineModel.file isEqual:comparedLineModel.file]
            && [lineModel.language isEqualToString:comparedLineModel.language]
            && [lineModel.key isEqualToString:comparedLineModel.key];
        }].array firstObject];
        
        if (matchedLineModel)//如果lineModel已经存在，获取其在string文件中原本的位置
        {
            comparedLineModel.order = matchedLineModel.order;
        }
        else//不存在说明是新增的文案(比如原来只有简体中文，新增了繁体或者英文翻译)
        {
            comparedLineModel.order = newLine;
            newLine++;
        }
    }];
    
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

@end
