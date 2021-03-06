//
//  NSFStringFilesMixTransformer.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/20.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFStringFilesMixTransformer.h"
#import "NSFStringsFileAndLineModelTransformer.h"
#import "NSFStringsLineModel.h"
#import "NSFKeyValueModel.h"
#import "NSFSetting.h"
#import "NSFProjectParseConfigration.h"

@implementation NSFStringFilesMixTransformer

+ (NSArray<NSURL *> *)regenerateAllStringFilesIn:(NSURL *)projectRoot
{
    [[NSFileManager defaultManager] removeItemAtURL:[NSFProjectParseConfigration tempFolder] error:nil];
    
    NSArray<NSURL *> *infoPlistStrings = [self p_stringFilesFromInfoPlistIn:projectRoot];
    
    NSArray<NSURL *> *sourceCodeStringFiles = [self p_stringFilesFromSourceCodeIn:projectRoot];
    sourceCodeStringFiles = [sourceCodeStringFiles.rac_sequence flattenMap:^__kindof RACSequence *(NSURL *fileURL) {
        NSURL *zh_hans = [[NSFProjectParseConfigration projectZh_HansLprojURLIn:projectRoot]
                          URLByAppendingPathComponent:NSFMainStringFileName];
        NSURL *zh_hant = [[NSFProjectParseConfigration projectZh_HantLprojURLIn:projectRoot]
                          URLByAppendingPathComponent:NSFMainStringFileName];
        NSURL *en = [[NSFProjectParseConfigration projectENLprojURLIn:projectRoot]
                     URLByAppendingPathComponent:NSFMainStringFileName];
        
        [NSFileManager nsf_copyItemAtURL:fileURL toURL:zh_hans];
        [NSFileManager nsf_copyItemAtURL:fileURL toURL:zh_hant];
        [NSFileManager nsf_copyItemAtURL:fileURL toURL:en];
        
        return @[zh_hans, zh_hant, en].rac_sequence;
    }].array;
    
    NSArray<NSURL *> *IBFiles = [self p_IBFilesIn:projectRoot];
    NSArray<NSURL *> *IBStringFiles = [IBFiles.rac_sequence flattenMap:^__kindof RACSequence *(NSURL *fileURL) {
        NSURL *stringFile = [self p_stringFileFromInterfaceBuilderFile:fileURL adjustKeys:NO];
        if (stringFile)
        {
            NSURL *baseURL = [[fileURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
            NSURL *zh_hans = [[baseURL URLByAppendingPathComponent:@"zh-Hans.lproj"] URLByAppendingPathComponent:[stringFile lastPathComponent]];
            NSURL *zh_hant = [[baseURL URLByAppendingPathComponent:@"zh-Hant.lproj"] URLByAppendingPathComponent:[stringFile lastPathComponent]];
            NSURL *en = [[baseURL URLByAppendingPathComponent:@"en.lproj"] URLByAppendingPathComponent:[stringFile lastPathComponent]];
            
            [NSFileManager nsf_copyItemAtURL:stringFile toURL:zh_hans];
            [NSFileManager nsf_copyItemAtURL:stringFile toURL:zh_hant];
            [NSFileManager nsf_copyItemAtURL:stringFile toURL:en];
            
            return @[zh_hans, zh_hant, en].rac_sequence;
        }
        
        return nil;
    }].array;
    
    [[NSFileManager defaultManager] removeItemAtURL:[NSFProjectParseConfigration tempFolder] error:nil];
    
    return [infoPlistStrings.rac_sequence
            concat:[[[sourceCodeStringFiles.rac_sequence
                      concat:[self p_schoolVersionStringsFilesFrom:sourceCodeStringFiles].rac_sequence]
                     concat:[self p_schoolVersionStringsFilesFrom:IBStringFiles].rac_sequence]
                    concat:IBStringFiles.rac_sequence]].array;
}

+ (NSString *)mixedStringFileContentFrom:(NSURL *)projectRoot
{
    [[NSFileManager defaultManager] removeItemAtURL:[NSFProjectParseConfigration tempFolder] error:nil];
    
    NSArray<NSURL *> *fileURLs = [[self p_stringFilesFromSourceCodeIn:projectRoot].rac_sequence
                                  concat:[self p_stringFilesFromInterfaceBuilderFilesIn:projectRoot].rac_sequence].array;
    
    NSMutableArray<NSFStringsLineModel *> *lineModels = [NSMutableArray array];
    [fileURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        NSString *seperatorComment = [NSString stringWithFormat:@"//===============================================%@===============================================", [[fileURL URLByDeletingPathExtension] lastPathComponent]];
        NSFCommentLineModel *seperator = [[NSFCommentLineModel alloc] initWithFile:fileURL
                                                                             order:NSNotFound
                                                                           content:seperatorComment];
        [lineModels addObject:seperator];
        
        NSFBlankLineModel *blankLine = [[NSFBlankLineModel alloc] initWithFile:fileURL order:NSNotFound content:@""];
        [lineModels addObject:blankLine];
        
        [lineModels addObjectsFromArray:[NSFStringsFileAndLineModelTransformer lineModelsFrom:fileURL]];
    }];
    
    //清除合并后可能key重复的lineModels，只保留第一个【即Localizable.strings中的那一行】
    NSMutableDictionary<NSString *, NSMutableArray<NSFStringsLineModel *> *> *duplicatedLineModels = [NSMutableDictionary dictionary];
    [lineModels enumerateObjectsUsingBlock:^(NSFStringsLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        NSFKeyValueModel *model = [NSFKeyValueModel safelyCast:lineModel];
        if (model)
        {
            if ([duplicatedLineModels.allKeys containsObject:model.key])
            {
                NSMutableArray<NSFStringsLineModel *> *models = duplicatedLineModels[model.key];
                model.order = idx;
                [models addObject:model];
                
                if (idx > 0)
                {
                    NSFCommentLineModel *comment = lineModels[idx - 1];
                    comment.order = idx - 1;
                    [models addObject:comment];
                }
                
                if (idx < lineModels.count - 1)
                {
                    NSFBlankLineModel *blank = lineModels[idx + 1];
                    blank.order = idx + 1;
                    [models addObject:blank];
                }
            }
            else
            {
                duplicatedLineModels[model.key] = [NSMutableArray array];
            }
        }
    }];
    
    [[[duplicatedLineModels.allValues.rac_sequence filter:^BOOL(NSMutableArray<NSFStringsLineModel *> *lineModels) {
        return lineModels.count > 0;
    }] flattenMap:^__kindof RACSequence *(NSMutableArray<NSFStringsLineModel *> *lineModels) {
        return lineModels.rac_sequence;
    }].array enumerateObjectsUsingBlock:^(NSFStringsLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        [lineModels removeObject:lineModel];
    }];
    
    //为去重后的lineModel排定行数，以便写入到strings文件中
    [lineModels enumerateObjectsUsingBlock:^(NSFStringsLineModel *lineModel, NSUInteger idx, BOOL *stop) {
        lineModel.order = idx;
    }];
    
    [[NSFileManager defaultManager] removeItemAtURL:[NSFProjectParseConfigration tempZh_HansLprojURL] error:nil];
    
    return [NSFStringsFileAndLineModelTransformer stringsFileContentFrom:lineModels];
}

#pragma mark - Private
+ (NSArray<NSURL *> *)p_stringFilesFromInfoPlistIn:(NSURL *)projectRoot
{
    return [NSFileManager nsf_filesThatMatch:^BOOL(NSURL *URL) {
        return [[URL lastPathComponent] hasSuffix:@"InfoPlist.strings"];
    } inFolder:projectRoot ignoreSubFolderThatMatch:^BOOL(NSURL *URL) {
        return [[URL absoluteString] containsString:@"Carthage"]
        || [[URL path] containsString:@"Pods"]
        || [[URL path] containsString:@"CoolOffice_UnitTests"];
    }];
}

+ (NSArray<NSURL *> *)p_stringFilesFromSourceCodeIn:(NSURL *)projectRoot
{
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = [projectRoot path];
    [task setLaunchPath:@"/bin/sh"];
    
    //防止在Console中输出error log
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];
    
    NSURL *folderURL = [NSFProjectParseConfigration tempZh_HansLprojURL];
    [[NSFileManager defaultManager] createDirectoryAtPath:[folderURL path] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *command = [NSString stringWithFormat:@"find . -type f \\( -iname \\*.h -o -iname \\*.m -o -iname \\*.swift \\) -not -path '*/Pods/*' -not -path '*/Carthage/*' | xargs genstrings -o %@ -s NLS", [folderURL path]];
    task.arguments = @[@"-c", command];
    
    [task launch];
    [task waitUntilExit];
    
    //genstrings生成的.strings文件是UTF-16 Little endian编码的，需要转换成UTF-8才能被Xcode识别
    NSArray<NSURL *> *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folderURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    [fileURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        [NSFileManager nsf_convertContentEncodingOfFileAt:fileURL encoding:NSUTF8StringEncoding];
    }];
    
    return fileURLs;
}

+ (NSArray<NSURL *> *)p_stringFilesFromInterfaceBuilderFilesIn:(NSURL *)projectRoot
{
    NSArray<NSURL *> *files = [self p_IBFilesIn:projectRoot];
    
    NSMutableArray<NSURL *> *stringFiles = [NSMutableArray array];
    [files enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
        NSURL *stringFile = [self p_stringFileFromInterfaceBuilderFile:URL adjustKeys:YES];
        if (stringFile)
        {
            [stringFiles addObject:stringFile];
        }
    }];
    
    return stringFiles;
}

+ (NSURL *)p_stringFileFromInterfaceBuilderFile:(NSURL *)fileURL
                                       adjustKeys:(BOOL)adjustKeys
{
    NSURL *folderURL = [NSFProjectParseConfigration tempZh_HansLprojURL];
    NSString *stringFileName = [[[fileURL lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"strings"];
    NSURL *stringFile = [folderURL URLByAppendingPathComponent:stringFileName];
    
    NSString *command = [NSString stringWithFormat:@"ibtool %@ --generate-strings-file %@",
                         [fileURL lastPathComponent],
                         [stringFile path]];
    
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = [[fileURL URLByDeletingLastPathComponent] path];
    [task setLaunchPath:@"/bin/sh"];
    task.arguments = @[@"-c", command];
    
    [task launch];
    [task waitUntilExit];
    
    NSString *content = [[NSString alloc] initWithContentsOfURL:stringFile usedEncoding:nil error:nil];
    if ([content isEqualToString:@"\n"])//ibtool生成的.strings文件至少会包含一个换行符
    {
        return nil;
    }
    
    [NSFileManager nsf_convertContentEncodingOfFileAt:stringFile
                                             encoding:NSUTF8StringEncoding];
    if (adjustKeys)
    {
        [NSFStringsFileAndLineModelTransformer adjustedStringFileContentFromIBFile:stringFile];
    }
    
    return stringFile;
}

+ (NSArray<NSURL *> *)p_IBFilesIn:(NSURL *)projectRoot
{
    return [NSFileManager nsf_filesThatMatch:^BOOL(NSURL *URL) {
        return [[[URL path] pathExtension] isEqualToString:@"storyboard"]
        && ![[URL path] containsString:@"LivenessDetection"]
        && ![[URL path] containsString:@"IDVerify"]
        && ![[URL path] containsString:@"QBImagePicker"];
    } inFolder:projectRoot ignoreSubFolderThatMatch:^BOOL(NSURL *URL) {
        return [[URL absoluteString] containsString:@"Carthage"]
        || [[URL path] containsString:@"Pods"];
    }];
}

+ (NSArray<NSURL *> *)p_schoolVersionStringsFilesFrom:(NSArray<NSURL *> *)stringFiles
{
    return [stringFiles.rac_sequence map:^id(NSURL *fileURL) {
        NSString *name = [NSString stringWithFormat:@"%@%@", NSFSchoolVersionPrefix, [fileURL lastPathComponent]];
        NSURL *schoolURL = [fileURL nsf_URLByReplacingLastPathComponentWith:name];
        
        NSString *content = [[NSString alloc] initWithContentsOfURL:fileURL usedEncoding:nil error:nil];
        [content writeToURL:schoolURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        return schoolURL;
    }].array;
}

@end
