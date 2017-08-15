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
@property (nonatomic, strong) NSMutableDictionary *internalTranslations;

@end


@implementation NSFLanguagePackLineModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.internalTranslations = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSString *)UUID
{
    if (!_UUID)
    {
        _UUID = [self.translations.allValues componentsJoinedByString:@"_"];
    }
    
    return _UUID;
}

- (NSDictionary<NSNumber *, NSString *> *)translations
{
    return self.internalTranslations;
}

- (void)setTranslations:(NSDictionary<NSNumber *,NSString *> *)translations
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

#pragma mark - Printable
- (NSString *)description
{
    return [self.translations.allValues componentsJoinedByString:@", "];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [@{@"key": self.isKeyMadeup ? @"" : self.key,
                                   @"row": @(self.row - 1)} mutableCopy];
    [self.translations enumerateKeysAndObjectsUsingBlock:^(NSNumber *language, NSString *translation, BOOL *stop) {
        dict[HumanReadable(language.integerValue)] = translation;
    }];
    
    return dict;
}

@end
