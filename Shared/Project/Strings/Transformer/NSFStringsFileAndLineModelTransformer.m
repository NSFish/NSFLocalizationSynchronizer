//
//  NSFStringsFileAndLineModelTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFStringsFileAndLineModelTransformer.h"
#import "NSFKeyValueModel.h"

@implementation NSFStringsFileAndLineModelTransformer

+ (NSArray<__kindof NSFStringsLineModel *> *)lineModelsFrom:(NSURL *)stringsFileURL
{
    return [self p_lineModelsFrom:stringsFileURL adjustIBGeneratedKey:NO];
}

+ (NSString *)stringsFileContentFrom:(NSArray<__kindof NSFStringsLineModel *> *)lineModels
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    lineModels = [lineModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableString *content = [NSMutableString string];
    for (NSFStringsLineModel *model in lineModels)
    {
        NSFKeyValueModel *keyValueModel = [NSFKeyValueModel safelyCast:model];
        if (keyValueModel)
        {
            NSMutableString *value = [NSMutableString new];
            
            //TODO:移动到单独的流程里做
            //兼容未转义的双引号
            __block NSString *previousSubstring = @"";
            [keyValueModel.value enumerateSubstringsInRange:NSMakeRange(0, keyValueModel.value.length)
                                                    options:NSStringEnumerationByComposedCharacterSequences
                                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                     if ([substring isEqualToString:@"\""]
                                                         && ![previousSubstring isEqualToString:@"\\"])
                                                     {
                                                         [value appendString:@"\\\""];
                                                     }
                                                     else
                                                     {
                                                         [value appendString:substring];
                                                     }
                                                     
                                                     previousSubstring = substring;
                                                 }];
            
            keyValueModel.value = [value copy];
            keyValueModel.content = [NSString stringWithFormat:@"\"%@\" = \"%@\";", keyValueModel.key, keyValueModel.value];
        }
        
        if ([model isEqual:[lineModels lastObject]])
        {
            [content appendString:model.content];
        }
        else
        {
            [content appendFormat:@"%@\n", model.content];
        }
    }
    
    return [content copy];
}

+ (NSString *)adjustedStringFileContentFromIBFile:(NSURL *)fileURL
{
    NSArray<NSFStringsLineModel *> *lineModels = [NSFStringsFileAndLineModelTransformer p_lineModelsFrom:fileURL
                                                                                      adjustIBGeneratedKey:YES];
    NSString *content = [self stringsFileContentFrom:lineModels];
    [content writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}

#pragma mark - Private
+ (NSFLanguage)p_languageRepresentByFile:(NSURL *)URL
{    
    BOOL schoolized = [[URL lastPathComponent] hasPrefix:@"school_"];
    NSString *path = [URL absoluteString];
    if ([path containsString:@"zh-Hans.lproj"])
    {
        if (schoolized)
        {
            return NSFLanguageSchoolizedSimplifiedChinese;
        }
        else
        {
            return NSFLanguageSimplifiedChinese;
        }
    }
    else if ([path containsString:@"zh-Hant.lproj"])
    {
        if (schoolized)
        {
            return NSFLanguageSchoolizedTraditionalChinese;
        }
        else
        {
            return NSFLanguageTraditionalChinese;
        }
    }
    else
    {
        if (schoolized)
        {
            return NSFLanguageSchoolizedEnglish;
        }
        else
        {
            return NSFLanguageEnglish;
        }
    }
}

+ (NSArray<__kindof NSFStringsLineModel *> *)p_lineModelsFrom:(NSURL *)stringsFileURL
                                           adjustIBGeneratedKey:(BOOL)adjustIBGeneratedKey
{
    NSFLanguage language = [self p_languageRepresentByFile:stringsFileURL];
    
    NSString *content = [NSString stringWithContentsOfURL:stringsFileURL encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
    
    //逐行解析，拆分成空白行、注释行和文案行
    NSMutableArray<__kindof NSFStringsLineModel *> *models = [NSMutableArray array];
    __block BOOL inTheMiddleOfCStyleComment = NO;
    
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        if (line.length == 0)
        {
            NSFBlankLineModel *model = [NSFBlankLineModel modelAtFile:stringsFileURL
                                                                order:idx
                                                              content:line];
            [models addObject:model];
        }
        else if ([line isComment] || inTheMiddleOfCStyleComment)
        {
            NSFCommentLineModel *model = [NSFCommentLineModel modelAtFile:stringsFileURL
                                                                    order:idx
                                                                  content:line];
            [models addObject:model];
            
            if ([line isStartOfCStyleCommentBlock])
            {
                inTheMiddleOfCStyleComment = YES;
            }
            else if ([line isEndOfCStyleCommentBlock])
            {
                inTheMiddleOfCStyleComment = NO;
            }
        }
        else
        {
            RACTuple *tuple = [line keyAndValue];
            NSString *key = tuple[0];
            NSString *value = tuple[1];
            
            if (adjustIBGeneratedKey
                && idx > 0)
            {
                NSString *previousLine = lines[idx - 1];
                if ([previousLine isUsefulComment])
                {
                    key = [previousLine possibleKey];
                }
            }
            
            NSFKeyValueModel *model = [NSFKeyValueModel modelAtFile:stringsFileURL
                                                              order:idx
                                                                key:key
                                                              value:value
                                                           language:language];
            model.content = line;
            [models addObject:model];
        }
    }];
    
    return [models copy];
}

@end
