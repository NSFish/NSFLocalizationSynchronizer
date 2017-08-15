//
//  BLIntermediaModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsLineModel.h"

@implementation NSFStringsLineModel

+ (instancetype)modelAtFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content
{
    return [[self alloc] initWithFile:file order:order content:content];
}

- (instancetype)initWithFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content
{
    if (self = [super init])
    {
        self.file = file;
        self.order = order;
        self.content = content;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", self.file, self.content];
}

- (NSDictionary *)toDictionary
{
    return @{@"file": self.file,
             @"order": @(self.order),
             @"content": self.content};
}

@end


@implementation NSString(LineInStringsFile)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isComment
{
    return [self hasPrefix:@"//"]
    || [self isCStyleComment]
    || [self isStartOfCStyleCommentBlock]
    || [self isEndOfCStyleCommentBlock];
}

- (BOOL)isUsefulComment
{
    return [self isComment] && [self containsString:@"ObjectID"];
}

- (NSString *)possibleKey
{
    NSString *middle = [self componentsSeparatedByString:@";"][1];
    NSString *text = [[middle componentsSeparatedByString:@"="][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSRange range = [self rangeOfString:text];
    NSInteger fromIndex = range.location + range.length + 4;
    
    range = [self rangeOfString:@"ObjectID"];
    NSInteger toIndex = range.location - 3;
    NSString *string = [self substringWithRange:NSMakeRange(fromIndex, toIndex - fromIndex)];
    
    return string;
}

- (BOOL)isCStyleComment
{
    NSString *trimedSelf = [self trim];
    return [trimedSelf hasSuffix:@"/*"]
    && [trimedSelf hasSuffix:@"*/"];
}

- (BOOL)isStartOfCStyleCommentBlock
{
    NSString *trimedSelf = [self trim];
    if (![trimedSelf hasPrefix:@"/*"])
    {
        return NO;
    }
    
    NSRange range = [trimedSelf rangeOfString:@"*/" options:NSBackwardsSearch];
    if (range.location + range.length <= trimedSelf.length)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)isEndOfCStyleCommentBlock
{
    NSString *trimedSelf = [self trim];
    if (![trimedSelf hasSuffix:@"*/"])
    {
        return NO;
    }
    
    NSRange range = [trimedSelf rangeOfString:@"/*" options:NSLiteralSearch];
    if (range.location > 0)
    {
        return NO;
    }
    
    return YES;
}

- (RACTuple *)keyAndValue
{
    NSArray *array = [self componentsSeparatedByString:@"="];
    NSString *roughKey = [[array firstObject] trim];
    NSString *key = [roughKey substringWithRange:NSMakeRange(1, roughKey.length - 2)];//去掉双引号
    
    NSString *roughValue = [[array lastObject] trim];
    NSString *value = [roughValue substringWithRange:NSMakeRange(1, roughValue.length - 3)];
    
    return RACTuplePack(key, value);
}

- (NSString *)fixPlaceHolder
{
    if ([self containsString:@"%"])
    {
        NSString *string = [self stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
        string = [string stringByReplacingOccurrencesOfString:@"$s" withString:@"$@"];
        
        if (![self isEqualToString:string])
        {
            return string;
        }
    }
    
    return self;
}

@end

