//
//  BLModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLanguagePackLineModel.h"

@implementation NSFLanguagePackLineModel
@synthesize zh_Hans, zh_Hant, en;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.zh_Hans, self.zh_Hant, self.en];
}

- (NSDictionary *)toDictionary
{
    return @{@"row": @(self.row - 1).stringValue,
             @"key": self.key,
             @"zh-Hans": self.zh_Hans,
             @"zh-Hant": self.zh_Hant,
             @"en": self.en,
             @"file": @""};
}

@end
