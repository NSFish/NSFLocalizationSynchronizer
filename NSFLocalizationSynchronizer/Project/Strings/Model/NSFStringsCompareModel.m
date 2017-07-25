//
//  NSFCompoundIntermediaModel.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsCompareModel.h"

@interface NSFStringsCompareModel()
@property (nonatomic, strong) NSMutableArray<NSString *> *keys;

@end


@implementation NSFStringsCompareModel
@synthesize zh_Hans, zh_Hant, en;

- (instancetype)init
{
    if (self = [super init])
    {
        self.keys = [NSMutableArray array];
    }
    
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{@"keys": [self.keys componentsJoinedByString:@", "],
             @"zh_Hans": self.zh_Hans ? self.zh_Hans : @"",
             @"zh-Hant": self.zh_Hant ? self.zh_Hant : @"",
             @"en": self.en ? self.en : @""};
}

@end
