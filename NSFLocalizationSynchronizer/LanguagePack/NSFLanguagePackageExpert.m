//
//  YFYLocalizedExcelFileHandler.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLanguagePackageExpert.h"
#import <XlsxReaderWriter/XlsxReaderWriter.h>
#import "BRAWorksheet+YFYExt.h"
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
    self.lineModels = [self lineModelsFromExcel:self.URL];
    return [self.lineModels copy];
}

- (void)updateCompareModels:(NSArray<NSFLanguagePackLineModel *> *)compareModels
{
    //读取原语言包的样式
    NSString *syncXlsxFilePath = [NSFSetting languageFilePath];
    BRAOfficeDocumentPackage *syncXlsxFile = [BRAOfficeDocumentPackage open:syncXlsxFilePath];
    BRAWorksheet *syncSheet = [syncXlsxFile.workbook.worksheets firstObject];
    BRACellFill *keyFill = [[syncSheet cellAtRow:10 col:1] cellFill];
    
    //构造新的语言包文件
    {
        BRAWorksheet *sheet = [self.xlsxFile.workbook.worksheets firstObject];
        
        NSUInteger cols = sheet.columns.count;
        NSUInteger currentRow = 2;
        
        //根据列标题读取各列index
        NSUInteger zh_HansIndex = NSNotFound, zh_HantIndex = NSNotFound, enIndex = NSNotFound, keyIndex = NSNotFound, platformIndex = NSNotFound;
        for (NSInteger col = 1; col < cols; ++col)
        {
            NSString *content = [sheet cellAtRow:currentRow col:col].stringValue;
            if ([content isEqualToString:@"中文"])
            {
                zh_HansIndex = col;
            }
            else if ([content isEqualToString:@"英文"])
            {
                enIndex = col;
            }
            else if ([content isEqualToString:@"繁体"])
            {
                zh_HantIndex = col;
            }
            else if ([content isEqualToString:@"Key"])
            {
                keyIndex = col;
            }
            else if ([content isEqualToString:@"Platform"])
            {
                platformIndex = col;
            }
        }
        
        //xlsx模板中只有1行，需要补足
        NSUInteger lackRows = syncSheet.rows.count - sheet.rows.count;
        if (lackRows > 0)
        {
            [sheet addRowsAt:sheet.rows.count count:lackRows];
        }
        
        [compareModels enumerateObjectsUsingBlock:^(NSFLanguagePackLineModel *model, NSUInteger idx, BOOL *stop) {
            [sheet cellAtRow:model.row col:keyIndex].stringValue = model.key;
            [sheet cellAtRow:model.row col:zh_HansIndex].stringValue = model.zh_Hans;
            [sheet cellAtRow:model.row col:zh_HantIndex].stringValue = model.zh_Hant;
            [sheet cellAtRow:model.row col:enIndex].stringValue = model.en;
            [sheet cellAtRow:model.row col:platformIndex].stringValue = model.platform;
            
            [sheet cellAtRow:model.row col:keyIndex].cellFill = keyFill;
        }];
    }
    
    [self.xlsxFile save];
}

#pragma mark - Private
- (NSArray<NSFLanguagePackLineModel *> *)lineModelsFromExcel:(NSURL *)URL
{
    BRAWorksheet *sheet = [self.xlsxFile.workbook.worksheets firstObject];
    
    NSInteger rows = sheet.rows.count;
    NSInteger cols = sheet.columns.count;
    
    //先解析标题行，区分出不同语言在哪一列
    NSUInteger currentRow = 2;
    NSUInteger zh_HansIndex = NSNotFound, zh_HantIndex = NSNotFound, enIndex = NSNotFound, keyIndex = NSNotFound, platformIndex = NSNotFound;
    for (NSInteger col = 1; col < cols; ++col)
    {
        NSString *content = [sheet cellAtRow:currentRow col:col].stringValue;
        if ([content isEqualToString:@"中文"])
        {
            zh_HansIndex = col;
        }
        else if ([content isEqualToString:@"英文"])
        {
            enIndex = col;
        }
        else if ([content isEqualToString:@"繁体"])
        {
            zh_HantIndex = col;
        }
        else if ([content isEqualToString:@"Key"])
        {
            keyIndex = col;
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
            model.file = URL;
            model.row = row;
            
            if (keyIndex != NSNotFound)
            {
                model.key = [sheet cellAtRow:row col:keyIndex].stringValue;
                if (model.key.length == 0)//没有key的新文案，生成一个临时key占位
                {
                    model.key = [[NSUUID UUID] UUIDString];
                }
            }
            
            if (zh_HansIndex != NSNotFound)
            {
                model.zh_Hans = [sheet cellAtRow:row col:zh_HansIndex].stringValue;
            }
            
            if (zh_HantIndex != NSNotFound)
            {
                model.zh_Hant = [sheet cellAtRow:row col:zh_HantIndex].stringValue;
            }
            
            if (enIndex != NSNotFound)
            {
                model.en = [sheet cellAtRow:row col:enIndex].stringValue;
            }
            
            if (platformIndex != NSNotFound)
            {
                model.platform = [sheet cellAtRow:row col:platformIndex].stringValue;
            }
            
            @synchronized (models) {
                [models addObject:model];
            }
        }
    });
    
    return [NSArray arrayWithArray:models];
}

@end
