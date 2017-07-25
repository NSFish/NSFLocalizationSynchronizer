//
//  NSFStringsLanguageModel.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsLanguageModel.h"
#import "NSFKeyValueModel.h"

@interface NSFStringsLanguageModel()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURL *> *fileURLs;

@end


@implementation NSFStringsLanguageModel
@synthesize zh_Hans = _zh_Hans, zh_Hant = _zh_Hant, en = _en;

- (instancetype)init
{
    if (self = [super init])
    {
        self.fileURLs = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSString *)UUID
{
    return [NSString stringWithFormat:@"%@_%@_%@", self.zh_Hans, self.zh_Hant, self.en];
}

- (void)integrate:(NSFKeyValueModel *)keyValueModel
{
    if ([keyValueModel.language isEqualToString:ZH_HANS])
    {
        self.zh_Hans = keyValueModel.value;
        self.fileURLs[ZH_HANS] = keyValueModel.file;
    }
    else if ([keyValueModel.language isEqualToString:ZH_HANT])
    {
        self.zh_Hant = keyValueModel.value;
        self.fileURLs[ZH_HANT] = keyValueModel.file;
    }
    else if ([keyValueModel.language isEqualToString:EN])
    {
        self.en = keyValueModel.value;
        self.fileURLs[EN] = keyValueModel.file;
    }
}

@end
