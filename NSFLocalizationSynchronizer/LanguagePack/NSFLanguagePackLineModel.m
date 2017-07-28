//
//  BLModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLanguagePackLineModel.h"

@interface NSFLanguagePackLineModel()
@property (nonatomic, strong) NSString *UUID;

@end


@implementation NSFLanguagePackLineModel
@synthesize zh_Hans = _zh_Hans, zh_Hant = _zh_Hant, en = _en;

- (NSString *)UUID
{
    if (!_UUID)
    {
        _UUID = [NSString stringWithFormat:@"%@_%@_%@", self.zh_Hans, self.zh_Hant, self.en];
    }
    
    return _UUID;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.zh_Hans, self.zh_Hant, self.en];
}

- (NSDictionary *)toDictionary
{
    return @{@"key": self.isKeyMadeup ? @"" : self.key,
             @"row": @(self.row - 1).stringValue,
             @"zh-Hans": self.zh_Hans,
             @"zh-Hant": self.zh_Hant,
             @"en": self.en};
}

@end
