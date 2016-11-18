//
//  YFYLocalizedStrinsFileHandler.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "YFYLocalizedStrinsFileHandler.h"
#import <ReactiveCocoa.h>
#import "YFYBlankModel.h"
#import "YFYCommentModel.h"
#import "YFYKeyValueModel.h"
#import "NSString+LineInStringsFile.h"
#import "NSFStringsReduntantableIntermediaModel.h"

@interface YFYLocalizedStrinsFileHandler()
@property (nonatomic, copy)   NSURL *projectRootDirectory;

/**
 *  从.strings文件中解析出来的原始数据，包含每一行的位置，写回时需要依赖它来保证写入的位置与之前一样
 */
@property (nonatomic, strong) NSArray *lineModels;

@end


@implementation YFYLocalizedStrinsFileHandler

- (instancetype)initWithProjectRootDirectory:(NSURL *)projectRootDirectory
{
    if (self = [super init])
    {
        self.projectRootDirectory = projectRootDirectory;
    }
    
    return self;
}

- (NSArray<NSFStringsIntermediaModel *> *)intermediaModels
{
    NSArray<NSURL *> *stringFileURLs = [self stringFilesUnderProjectRootDirectory];
//        NSArray<NSURL *> *stringFileURLs = [[self stringFilesUnderProjectRootDirectory].rac_sequence filter:^BOOL(id value) {
//            return [[value path] containsString:@"Localizable"];
//        }].array;
    
    //先逐个解析.strings文件，生成初级的中间数据
    NSMutableArray *lineModels = [NSMutableArray array];
    for (NSURL *URL in stringFileURLs)
    {
        [lineModels addObjectsFromArray:[self lineModelsFromStringFile:URL]];
    }
    
    //暂存起来供写回.strings文件时使用
    self.lineModels = [NSArray arrayWithArray:lineModels];
    
    //只取包含键值对的行
    NSArray<YFYKeyValueModel *> *usefulLineModels = [lineModels.rac_sequence filter:^BOOL(NSFStringsLineModel *model) {
        return [model isKindOfClass:[YFYKeyValueModel class]];
    }].array;
    
    //先将所有行数据整合成key -> zh-Hans、zh-Hant、en的格式
    NSMutableDictionary<NSString *, NSFStringsReduntantableIntermediaModel *> *intermediaModelDicts = [NSMutableDictionary dictionary];
    for (YFYKeyValueModel *lineModel in usefulLineModels)
    {
        //不同的.strings文件中可能存在key相同，但表征不同意义的键值对，比如多个target的infoPlist.strings文件中可能都有CFBundleDisplayName，因此这里需要
        //将文件路径也加入判定
        NSString *stringsFileRootFolder = [[[lineModel.file absoluteString] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        NSString *uniqueKey = [NSString stringWithFormat:@"%@_%@", lineModel.key, stringsFileRootFolder];
        NSFStringsReduntantableIntermediaModel *model = intermediaModelDicts[uniqueKey];
        if (!model)
        {
            model = [NSFStringsReduntantableIntermediaModel new];
            model.key = lineModel.key;
            intermediaModelDicts[uniqueKey] = model;
        }
        
        [model setValue:lineModel.value forKey:[self yfy_language2PropertyName:lineModel.language]];
    }
    
    //同一个文案可能同时出现在Localizable.strings、xib.strings和storyboard.strings中
    //而storyboard.strings和xib.strings文件中的key都是自动生成的objectID，因此会出现文案完全一致但key不一样的情况
    //对语言包而言这只能算是一条翻译，需要把多条文案整合到一起
    NSMutableDictionary<NSString *, NSMutableArray *> *mDict = [NSMutableDictionary dictionary];
    for (NSFStringsReduntantableIntermediaModel *reduntantableIntermediaModel in intermediaModelDicts.allValues)
    {
        NSString *UUID = [reduntantableIntermediaModel UUID];
        NSMutableArray *array = mDict[UUID];
        if (!array)
        {
            array = [NSMutableArray array];
            mDict[UUID] = array;
        }
        
        [array addObject:reduntantableIntermediaModel];
    }
    
    //生成最后的中间数据
    NSArray<NSFStringsIntermediaModel *> *intermediaModels = [mDict.allValues.rac_sequence map:^id(NSArray<NSFStringsReduntantableIntermediaModel *> *array) {
        NSFStringsIntermediaModel *intermediaModel = [NSFStringsIntermediaModel new];
        for (NSFStringsReduntantableIntermediaModel *model in array)
        {
            [intermediaModel addKey:model.key];
            intermediaModel.zh_Hans = model.zh_Hans;
            intermediaModel.zh_Hant = model.zh_Hant;
            intermediaModel.en = model.en;
        }
        
        return intermediaModel;
    }].array;
    
    return intermediaModels;
}

- (void)overrideStringFiles:(NSArray<NSFStringsIntermediaModel *> *)intermediaModels
{
    NSMutableArray *mLineModels = [NSMutableArray arrayWithArray:self.lineModels];
    
    NSArray<YFYKeyValueModel *> *models = [self.lineModels.rac_sequence filter:^BOOL(id value) {
        return [value isKindOfClass:[YFYKeyValueModel class]];
    }].array;
    
    void(^updateTranslations)(NSFStringsIntermediaModel *model, NSArray<YFYKeyValueModel *> *matchedLineModels, NSString *key, NSString *language) = ^(NSFStringsIntermediaModel *model, NSArray<YFYKeyValueModel *> *matchedLineModels, NSString *key, NSString *language)
    {
        YFYKeyValueModel *lineModel = [[matchedLineModels.rac_sequence filter:^BOOL(YFYKeyValueModel *model) {
            return [model.language isEqualToString:language];
        }].array firstObject];
        
        NSString *newValue = [model valueForKey:[self yfy_language2PropertyName:language]];
        if (newValue)
        {
            if (!lineModel)
            {
                YFYKeyValueModel *firstModel = [matchedLineModels firstObject];
                NSURL *file = [firstModel file];
                NSString *filePath = [[file path] stringByReplacingOccurrencesOfString:firstModel.language withString:language];
                file = [NSURL fileURLWithPath:filePath];
                
                lineModel = [YFYKeyValueModel modelAtFile:file order:self.lineModels.count key:key value:newValue language:language];
                [mLineModels addObject:lineModel];
            }
            else
            {
                lineModel.value = newValue;
            }
        }
    };
    
    //反向生成行数据
    for (NSFStringsIntermediaModel *intermediaModel in intermediaModels)
    {
        [intermediaModel.keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<YFYKeyValueModel *> *matchedLineModels = [models.rac_sequence filter:^BOOL(YFYKeyValueModel *model) {
                return [model.key isEqualToString:key];
            }].array;
            
            if (matchedLineModels.count > 0)
            {
                updateTranslations(intermediaModel, matchedLineModels, key, @"zh-Hans");
                updateTranslations(intermediaModel, matchedLineModels, key, @"zh-Hant");
                updateTranslations(intermediaModel, matchedLineModels, key, @"en");
            }
        }];
    }
    
    self.lineModels = [NSArray arrayWithArray:mLineModels];
    
    //整理所有的IntermediaModels，按文件分组，逐批写回
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSFStringsLineModel *model in self.lineModels)
    {
        NSMutableArray *array = nil;
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
    
    for (NSArray *array in dict.allValues)
    {
        [self writeToFile:array];
    }
}

- (void)writeToFile:(NSArray<NSFStringsLineModel *> *)models
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    models = [models sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableString *content = [NSMutableString string];
    for (NSFStringsLineModel *model in models)
    {
        if ([model isEqual:[models lastObject]])
        {
            [content appendString:model.content];
        }
        else
        {
            [content appendFormat:@"%@\n", model.content];
        }
    }
    
    [content writeToURL:models[0].file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Private
- (NSArray<NSURL *> *)stringFilesUnderProjectRootDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:self.projectRootDirectory
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error)
                                             {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             
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
    
    return [NSArray arrayWithArray:fileURLs];
}

- (NSArray<NSFStringsLineModel *> *)lineModelsFromStringFile:(NSURL *)stringFileURL
{
    NSString *language = [self yfy_languageRepresentByFile:stringFileURL];
    
    NSString *content = [NSString stringWithContentsOfURL:stringFileURL encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    //逐行解析，拆分成空白行、注释行和文案行
    NSMutableArray *models = [NSMutableArray array];
    
    {
        BOOL inTheMiddleOfCStyleComment = NO;
        for (NSUInteger i = 0; i< lines.count; ++i)
        {
            NSString *line = lines[i];
            
            if (line.length == 0)
            {
                YFYBlankModel *model = [YFYBlankModel modelAtFile:stringFileURL order:i content:line];
                [models addObject:model];
            }
            else if ([line isComment] || inTheMiddleOfCStyleComment)
            {
                YFYCommentModel *model = [YFYCommentModel modelAtFile:stringFileURL order:i content:line];
                [models addObject:model];
                
                if ([line isStartOfCStyleComment])
                {
                    inTheMiddleOfCStyleComment = YES;
                }
                else if ([line isEndOfCStyleComment])
                {
                    inTheMiddleOfCStyleComment = NO;
                }
            }
            else
            {
                RACTuple *tuple = [line keyAndValue];
                NSString *key = tuple[0];
                NSString *value = tuple[1];
                
                YFYKeyValueModel *model = [YFYKeyValueModel modelAtFile:stringFileURL order:i key:key value:value language:language];
                model.content = line;
                [models addObject:model];
            }
        }
    }
    
    return [NSArray arrayWithArray:models];
}

- (NSString *)yfy_languageRepresentByFile:(NSURL *)URL
{
    NSString *path = [URL absoluteString];
    if ([path containsString:@"zh-Hans.lproj"])
    {
        return @"zh-Hans";
    }
    else if ([path containsString:@"zh-Hant.lproj"])
    {
        return @"zh-Hant";
    }
    
    return @"en";
}

- (NSString *)yfy_language2PropertyName:(NSString *)language
{
    if ([language containsString:@"-"])
    {
        return [language stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    }
    
    return language;
}


@end

