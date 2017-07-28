//
//  YFYLocalizedExcelFileHandler.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLanguagePackageExpert.h"
#import <XlsxReaderWriter/XlsxReaderWriter.h>
#import "BRAWorksheet+NSFExt.h"
#import "NSFSetting.h"

#define _(X) (uint32_t)(X)

@interface NSFLanguagePackageExpert()
@property (nonatomic, copy)   NSURL *URL;
@property (nonatomic, strong) NSArray *lineModels;
@property (nonatomic, strong) BRAOfficeDocumentPackage *xlsxFile;

@end


@implementation NSFLanguagePackageExpert

+ (instancetype)create:(NSURL *)URL
{
    //目前的xlsx库不支持直接创建xlsx文件，这里变通一下，在App bundle里预置一个空的xlsx文件
    //复制到指定URL之后，再进行操作
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
    }
    NSURL *templateXlsxFileURL = [[NSBundle mainBundle] URLForResource:@"template" withExtension:@"xlsx"];
    [[NSFileManager defaultManager] copyItemAtURL:templateXlsxFileURL toURL:URL error:nil];
    
    return [self load:URL];
}

+ (instancetype)load:(NSURL *)URL
{
    NSFLanguagePackageExpert *handler = [NSFLanguagePackageExpert new];
    handler.xlsxFile = [BRAOfficeDocumentPackage open:[URL path]];
    handler.URL = URL;
    
    return handler;
}

- (NSArray<NSFLanguagePackLineModel *> *)compareModels
{
    BRAWorksheet *sheet = [self.xlsxFile.workbook.worksheets firstObject];
    
    NSInteger rows = sheet.rows.count;
    NSInteger cols = sheet.columns.count;
    
    //先解析标题行，区分出不同语言在哪一列
    NSUInteger currentRow = 2;
    NSUInteger keyIndex = NSNotFound,
    simplifiedChineseIndex = NSNotFound,
    traditionalChineseIndex = NSNotFound,
    EnglishIndex = NSNotFound,
    schoolizedSimplifiedChineseIndex = NSNotFound,
    schoolizedTraditionalChineseIndex = NSNotFound,
    schoolizedEnglishIndex = NSNotFound,
    platformIndex = NSNotFound;
    for (NSInteger col = 1; col < cols; ++col)
    {
        NSString *content = [sheet nsf_cellAtRow:currentRow col:col].stringValue;
        
        if ([content isEqualToString:@"Key"])
        {
            keyIndex = col;
        }
        else if ([content isEqualToString:@"中文"])
        {
            simplifiedChineseIndex = col;
        }
        else if ([content isEqualToString:@"繁体"])
        {
            traditionalChineseIndex = col;
        }
        else if ([content isEqualToString:@"英文"])
        {
            EnglishIndex = col;
        }
        else if ([content isEqualToString:@"高校版中文"])
        {
            schoolizedSimplifiedChineseIndex = col;
        }
        else if ([content isEqualToString:@"高校版繁体"])
        {
            schoolizedTraditionalChineseIndex = col;
        }
        else if ([content isEqualToString:@"高校版英文"])
        {
            schoolizedEnglishIndex = col;
        }
        else if ([content isEqualToString:@"Platform"])
        {
            platformIndex = col;
        }
    }
    
    currentRow++;
    NSUInteger totalRows = rows - currentRow + 1;
    NSUInteger batchs = 4;
    NSUInteger batchNum = totalRows / batchs;
    NSMutableArray<RACTuple *> *iterations = [NSMutableArray array];
    for (NSUInteger row = currentRow; row <= rows; row+= batchNum)
    {
        [iterations addObject:RACTuplePack(@(row), @(MIN(row + batchNum - 1, rows)))];
    }
    
    NSMutableArray *models = [NSMutableArray array];
    dispatch_apply([iterations count], dispatch_get_global_queue(0, 0), ^(size_t index) {
        RACTuple *iteration = iterations[index];
        
        for (NSUInteger row = [[iteration first] integerValue]; row <= [[iteration second] integerValue]; ++row)
        {
            NSFLanguagePackLineModel *model = [NSFLanguagePackLineModel new];
            model.row = row;
            
            if (keyIndex != NSNotFound)
            {
                model.key = [sheet nsf_cellAtRow:row col:keyIndex].stringValue;
                if (model.key.length == 0)//没有key的新文案，生成一个临时key占位
                {
                    model.key = [[NSUUID UUID] UUIDString];
                    model.isKeyMadeup = YES;
                }
            }
            
            if (simplifiedChineseIndex != NSNotFound)
            {
                [model setTranslation:[sheet nsf_cellAtRow:row col:simplifiedChineseIndex].stringValue
                          forLanguage:NSFLanguageSimplifiedChinese];
            }
            
            if (traditionalChineseIndex != NSNotFound)
            {
                [model setTranslation:[sheet nsf_cellAtRow:row col:traditionalChineseIndex].stringValue
                          forLanguage:NSFLanguageTraditionalChinese];
            }
            
            if (EnglishIndex != NSNotFound)
            {
                [model setTranslation:[sheet nsf_cellAtRow:row col:EnglishIndex].stringValue
                          forLanguage:NSFLanguageEnglish];
            }
            
            if (schoolizedSimplifiedChineseIndex != NSNotFound)
            {
                NSString *translation = [sheet nsf_cellAtRow:row col:schoolizedSimplifiedChineseIndex].stringValue;
                if (translation.length == 0)
                {
                    translation = [model translation4Language:NSFLanguageSimplifiedChinese];
                }
                
                [model setTranslation:translation forLanguage:NSFLanguageSchoolizedSimplifiedChinese];
            }
            
            if (schoolizedTraditionalChineseIndex != NSNotFound)
            {
                NSString *translation = [sheet nsf_cellAtRow:row col:schoolizedTraditionalChineseIndex].stringValue;
                if (translation.length == 0)
                {
                    translation = [model translation4Language:NSFLanguageTraditionalChinese];
                }
                
                [model setTranslation:translation forLanguage:NSFLanguageSchoolizedTraditionalChinese];
            }
            
            if (schoolizedEnglishIndex != NSNotFound)
            {
                NSString *translation = [sheet nsf_cellAtRow:row col:schoolizedEnglishIndex].stringValue;
                if (translation.length == 0)
                {
                    translation = [model translation4Language:NSFLanguageEnglish];
                }
                
                [model setTranslation:translation forLanguage:NSFLanguageSchoolizedEnglish];
            }
            
            if (platformIndex != NSNotFound)
            {
                model.platform = [sheet nsf_cellAtRow:row col:platformIndex].stringValue;
            }
            
            @synchronized (models) {
                [models addObject:model];
            }
        }
    });
    
    self.lineModels = [NSArray arrayWithArray:models];
    return self.lineModels;
}

- (void)updateCompareModels:(NSArray<NSFLanguagePackLineModel *> *)compareModels
{
    //todo:
}

#pragma mark - 扫描
- (NSDictionary *)scanKeyDuplicatedRows
{
    if (!self.lineModels)
    {
        self.lineModels = [self compareModels];
    }
    
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *strictLanguageModels = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *normalLanguageModels = [NSMutableDictionary dictionary];
    [self.lineModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *lineModel, NSUInteger idx, BOOL *stop) {
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
    
    NSMutableDictionary<NSString *, NSArray *> *duplicates = [NSMutableDictionary dictionary];
    [strictLanguageModels enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray<NSFLanguagePackLineModel *> *models, BOOL *stop) {
        if (models.count > 1)
        {
            duplicates[key] = [models.rac_sequence map:^id(NSFLanguagePackLineModel *model) {
                return [model toDictionary];
            }].array;
        }
    }];
    
    return duplicates.count > 0 ? duplicates : nil;
}

- (NSDictionary *)scanTranslationDuplicatedRows
{
    if (!self.lineModels)
    {
        self.lineModels = [self compareModels];
    }
    
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *languageModels = [NSMutableDictionary dictionary];
    [self.lineModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSMutableArray *strictLineModels = languageModels[lineModel.UUID];
        if (!strictLineModels)
        {
            languageModels[lineModel.UUID] = [@[lineModel] mutableCopy];
        }
        else
        {
            [strictLineModels addObject:lineModel];
        }
    }];
    
    NSMutableDictionary<NSString *, NSArray *> *duplicates = [NSMutableDictionary dictionary];
    [languageModels enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray<NSFLanguagePackLineModel *> *models, BOOL *stop) {
        if (models.count > 1)
        {
            duplicates[key] = [models.rac_sequence map:^id(NSFLanguagePackLineModel *model) {
                return @{@"Key": model.isKeyMadeup ? @"" : model.key,
                         @"Row": @(model.row)};
            }].array;
        }
    }];
    
    return duplicates.count > 0 ? duplicates : nil;
}

- (NSDictionary *)scanZh_HansDuplicatedOnlyRows
{
    if (!self.lineModels)
    {
        self.lineModels = [self compareModels];
    }
    
    NSMutableDictionary<NSString *, NSMutableArray<NSFLanguagePackLineModel *> *> *languageModels = [NSMutableDictionary dictionary];
    [self.lineModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSString *simplifiedChinese = [lineModel translation4Language:NSFLanguageSimplifiedChinese];
        
        NSMutableArray *strictLineModels = languageModels[simplifiedChinese];
        if (!strictLineModels)
        {
            languageModels[simplifiedChinese] = [@[lineModel] mutableCopy];
        }
        else
        {
            //只记录翻译不同的行
            BOOL sameTranslationsExist = [strictLineModels.rac_sequence any:^BOOL(NSFLanguagePackLineModel *model) {
                return [model.UUID isEqualToString:lineModel.UUID];
            }];
            
            if (!sameTranslationsExist)
            {
                [strictLineModels addObject:lineModel];
            }
        }
    }];
    
    NSMutableDictionary<NSString *, NSArray *> *duplicates = [NSMutableDictionary dictionary];
    [languageModels enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray<NSFLanguagePackLineModel *> *models, BOOL *stop) {
        if (models.count > 1)
        {
            duplicates[key] = [models.rac_sequence map:^id(NSFLanguagePackLineModel *model) {
                return [model toDictionary];
            }].array;
        }
    }];
    
    return duplicates.count > 0 ? duplicates : nil;
}

@end
