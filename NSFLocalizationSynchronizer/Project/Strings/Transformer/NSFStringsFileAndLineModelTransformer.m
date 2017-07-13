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
    NSString *language = [self yfy_languageRepresentByFile:stringsFileURL];
    
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
                                                         && ![previousSubstring isEqualToString:@"\\"]
                                                         && !(substringRange.location == 0
                                                              || substringRange.location + substringRange.length == keyValueModel.value.length))
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

#pragma mark - Private
+ (NSString *)yfy_languageRepresentByFile:(NSURL *)URL
{
    NSString *path = [URL absoluteString];
    if ([path containsString:@"zh-Hans.lproj"])
    {
        return ZH_HANS;
    }
    else if ([path containsString:@"zh-Hant.lproj"])
    {
        return ZH_HANT;
    }
    
    return EN;
}

@end
