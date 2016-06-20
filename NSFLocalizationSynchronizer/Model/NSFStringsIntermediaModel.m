//
//  NSFCompoundIntermediaModel.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsIntermediaModel.h"

@interface NSFStringsIntermediaModel()
@property (nonatomic, copy) NSArray<NSString *> *keys;

@end


@implementation NSFStringsIntermediaModel
@synthesize zh_Hans, zh_Hant, en;

- (void)addKey:(NSString *)key
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:self.keys];
    [keys addObject:key];
    self.keys = [NSArray arrayWithArray:keys];
}

- (NSDictionary *)toDictionary
{
    return @{@"keys": [self.keys componentsJoinedByString:@", "],
             @"zh_Hans": self.zh_Hans ? self.zh_Hans : @"",
             @"zh-Hant": self.zh_Hant ? self.zh_Hant : @"",
             @"en": self.en ? self.en : @""};
}

@end
