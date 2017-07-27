//
//  NSFSourceCodeScanner.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/10.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFSourceCodeScanner.h"
#import "NSFSetting.h"

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
    
    NSArray<NSURL *> *sourceFiles = [self allSourceFilesIn:projectURL];
    [sourceFiles enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        [fragments addObjectsFromArray:[self nonLocalizedStringsIn:fileURL]];
    }];
    
    return fragments;
}

#pragma mark - Private
+ (NSArray<NSURL *> *)allSourceFilesIn:(NSURL *)directoryURL
{
    return [NSFileManager nsf_filesThatMatch:^BOOL(NSURL *URL) {
        return [[URL lastPathComponent] hasSuffix:@".h"]
        || [[URL lastPathComponent] hasSuffix:@".m"]
        || [[URL lastPathComponent] hasSuffix:@".swift"];
    } inFolder:directoryURL ignoreSubFolderThatMatch:^BOOL(NSURL *URL) {
        return [[URL absoluteString] containsString:@"Carthage"]
        || [[URL path] containsString:@"Pods"]
        || [[URL path] containsString:@"CoolOffice_UnitTests"]
        || [[URL path] containsString:@"IDVerify"];
    }];
}

+ (NSArray<NSFSourceCodeFragment *> *)nonLocalizedStringsIn:(NSURL *)fileURL
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
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
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
                                 
                                 if ([stringContent stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]].length != 0
                                     && ![stringContent hasSuffix:@".h"]
                                     && ![line containsString:image]
                                     && ![line containsString:NLS]
                                     && ![line containsString:localizedString]
                                     && ![line containsString:MTATrackEvent]
                                     && ![self insideWhiteList:stringContent])
                                 {
                                     NSFSourceCodeFragment *fragment = [NSFSourceCodeFragment instanceWithContent:stringContent
                                                                                                       lineNumber:idx
                                                                                                          fileURL:fileURL];
                                     [fragments addObject:fragment];
                                     NSLog(@"%@\n\n", string);
                                 }
                             }];
    }];
    
    return fragments;
}

+ (BOOL)insideWhiteList:(NSString *)string
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
                           @"要先调用setContext传入workingContext!"
                           ];
    
    return [whiteList containsObject:string];
}

@end
