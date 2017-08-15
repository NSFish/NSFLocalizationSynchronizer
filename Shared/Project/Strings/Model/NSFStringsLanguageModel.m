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
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSURL *> *fileURLs;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *internalTranslations;

@end


@implementation NSFStringsLanguageModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.fileURLs = [NSMutableDictionary new];
        self.translations = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public
- (NSString *)UUID
{
    return [self.translations.allValues componentsJoinedByString:@"_"];
}

- (void)integrate:(NSFKeyValueModel *)keyValueModel
{
    [self setTranslation:keyValueModel.value forLanguage:keyValueModel.language];
    self.fileURLs[@(keyValueModel.language)] = keyValueModel.file;
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

@end
