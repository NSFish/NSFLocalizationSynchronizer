//
//  NSFSourceCodeScanner.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/10.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFSourceCodeScanner.h"
#import "NSFSetting.h"
#import "NSFStringsLineModel.h"

@interface NSFSourceCodeFragment()
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSUInteger lineNumber;
@property (nonatomic, copy) NSURL *fileURL;

@end

@implementation NSFSourceCodeFragment

+ (instancetype)instanceWithContent:(NSString *)content
                         lineNumber:(NSUInteger)lineNumber
                            fileURL:(NSURL *)fileURL
{
    NSFSourceCodeFragment *fragment = [NSFSourceCodeFragment new];
    fragment.content = content;
    fragment.lineNumber = lineNumber;
    fragment.fileURL = fileURL;
    
    return fragment;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,\n 行数：%@,\n 文件：%@", self.content, @(self.lineNumber), [self.fileURL path]];
}

- (NSDictionary *)toDictionary
{
    return @{@"内容": self.content,
             @"行数": @(self.lineNumber),
             @"文件": [self.fileURL path]};
}

@end


@implementation NSFSourceCodeScanner

+ (NSArray<NSFSourceCodeFragment *> *)findNonLocalizedStringsIn:(NSURL *)projectURL
{
    NSMutableArray<NSFSourceCodeFragment *> *fragments = [NSMutableArray array];
    
    NSArray<NSURL *> *sourceFiles = [self p_allSourceFilesIn:projectURL];
    [sourceFiles enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        [fragments addObjectsFromArray:[self p_nonLocalizedStringsIn:fileURL]];
    }];
    
    return fragments;
}

#pragma mark - Private
+ (NSArray<NSURL *> *)p_allSourceFilesIn:(NSURL *)directoryURL
{
    return [NSFileManager nsf_filesThatMatch:^BOOL(NSURL *URL) {
        return [[URL lastPathComponent] hasSuffix:@".h"]
        || [[URL lastPathComponent] hasSuffix:@".m"]
        || [[URL lastPathComponent] hasSuffix:@".swift"];
    } inFolder:directoryURL ignoreSubFolderThatMatch:^BOOL(NSURL *URL) {
        return [[URL absoluteString] containsString:@"Carthage"]
        || [[URL path] containsString:@"Pods"]
        || [[URL path] containsString:@"CoolOffice_UnitTests"]
        || [[URL path] containsString:@"IDVerify"]
        || [[URL path] containsString:@"KF5SDK"];
    }];
}

+ (NSArray<NSFSourceCodeFragment *> *)p_nonLocalizedStringsIn:(NSURL *)fileURL
{
    NSMutableArray<NSFSourceCodeFragment *> *fragments = [NSMutableArray array];
    
    NSString *content = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *lines = [[content componentsSeparatedByString:@"\n"].rac_sequence map:^id(NSString *line) {
        NSRange commentRange = [line rangeOfString:@"//"];
        if (commentRange.location == NSNotFound)
        {
            return line;
        }
        
        if (commentRange.location == 0)
        {
            return @"";
        }
        
        return [line substringToIndex:commentRange.location - 1];
    }].array;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(^|[^'])(@?\"([^\"\\\\]|(\\\\.)|(\\\\\n)|(\"\\s*@?\"))*\")" options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    __block BOOL insideCStyleCommentArea = NO;
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        if (insideCStyleCommentArea)
        {
            return;
        }
        
        if ([line isStartOfCStyleCommentBlock])
        {
            insideCStyleCommentArea = YES;
            return;
        }
        else if ([line isEndOfCStyleCommentBlock])
        {
            insideCStyleCommentArea = NO;
            return;
        }
        else if ([line isComment])
        {
            return;
        }
        
        if ([line containsString:@"NSLog"])
        {
            return;
        }
        
        [regex enumerateMatchesInString:line
                                options:0
                                  range:NSMakeRange(0, line.length)
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                 NSString *string = [line substringWithRange:[result rangeAtIndex:2]];
                                 
                                 __block BOOL containsChinese = NO;
                                 NSRegularExpression *chinese = [NSRegularExpression regularExpressionWithPattern:@"\\p{Script=Han}" options:NSRegularExpressionCaseInsensitive error:nil];
                                 [chinese enumerateMatchesInString:string
                                                           options:0
                                                             range:NSMakeRange(0, string.length)
                                                        usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                            containsChinese = YES;
                                                            *stop = YES;
                                                        }];
                                 
                                 if (!containsChinese)
                                 {
                                     return;
                                 }
                                 
                                 NSString *stringContent = string;
                                 if ([stringContent hasPrefix:@"@"])
                                 {
                                     stringContent = [string substringFromIndex:1];
                                 }
                                 
                                 //移除双引号
                                 stringContent = [stringContent substringWithRange:NSMakeRange(1, stringContent.length - 2)];
                                 
                                 NSString *image = [NSString stringWithFormat:@"[UIImage imageNamed:%@]", string];
                                 NSString *NLS = [NSString stringWithFormat:@"NLS(%@", string];
                                 NSString *localizedString = [NSString stringWithFormat:@"NSLocalizedString(%@", string];
                                 NSString *MTATrackEvent = [NSString stringWithFormat:@"MTATrackEvent(%@", string];
                                 NSString *MTACustomTrackEvent = [NSString stringWithFormat:@"trackCustomKeyValueEvent:%@", string];
                                 NSString *languageModel = [NSString stringWithFormat:@"YFYLanguage(%@", string];
                                 
                                 if (![stringContent hasSuffix:@".h"]
                                     && ![line containsString:image]
                                     && ![line containsString:NLS]
                                     && ![line containsString:localizedString]
                                     && ![line containsString:MTATrackEvent]
                                     && ![line containsString:MTACustomTrackEvent]
                                     && ![line containsString:languageModel]
                                     && ![self p_insideWhiteList:stringContent])
                                 {
                                     NSFSourceCodeFragment *fragment = [NSFSourceCodeFragment instanceWithContent:stringContent
                                                                                                       lineNumber:idx + 1
                                                                                                          fileURL:fileURL];
                                     [fragments addObject:fragment];
                                 }
                             }];
    }];
    
    return fragments;
}

+ (BOOL)p_insideWhiteList:(NSString *)string
{
    NSArray *whiteList = @[@"useless:只用于开发时方便处理边界值",
                           @"uploader:上传者",
                           @"previewer:预览者",
                           @"previewer_uploader:预览+上传者",
                           @"viewer:查看者",
                           @"viewer_uploader:查看+上传者",
                           @"editor:编辑者",
                           @"coowner:共同所有者",
                           @"owner:所有者",
                           @"iOS用户反馈%@",
                           @"无效的refresh_token ！！！！",
                           @"传入了URL:%@ 找不到对应的VC Class",
                           @"YFYPDFConfiguration 配置出错啦 ！！！",
                           @"出错了，这里不是主线程",
                           @"不存在invited = false但ownedByExternalUser = true的case",
                           @"要先调用setContext传入workingContext!",
                           @"邀请同事",
                           @"选择协作者级别",
                           @"添加常用",
                           @"邀请协作成员",
                           @"快速跳转",
                           @"筛选消息类型"
                           ];
    
    return [whiteList containsObject:string];
}

@end
