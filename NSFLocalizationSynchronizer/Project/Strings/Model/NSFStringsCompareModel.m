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
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *internalTranslations;

@end


@implementation NSFStringsCompareModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.keys = [NSMutableArray array];
        self.translations = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [@{@"keys": [self.keys componentsJoinedByString:@", "]} mutableCopy];
    [self.translations enumerateKeysAndObjectsUsingBlock:^(NSNumber *language, NSString *obj, BOOL *stop) {
        dict[HumanReadable(language.integerValue)] = obj;
    }];
    
    return dict;
}

- (NSDictionary<NSNumber *, NSString *> *)translations
{
    return self.internalTranslations;
}

- (void)setTranslations:(NSDictionary<NSNumber *, NSString *> *)translations
{
    self.internalTranslations = [translations mutableCopy];
}

- (NSString *)translation4Language:(NSFLanguage)language
{
    return self.internalTranslations[@(language)];
}

- (void)setTranslation:(NSString *)translation forLanguage:(NSFLanguage)language
{
    self.internalTranslations[@(language)] = translation;
}

@end
