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
    return [NSString stringWithFormat:@"%@, %@, %@", self.file, @(self.order), self.content];
}

- (NSDictionary *)toDictionary
{
    return @{@"file": self.file,
             @"order": @(self.order),
             @"content": self.content};
}


@end
