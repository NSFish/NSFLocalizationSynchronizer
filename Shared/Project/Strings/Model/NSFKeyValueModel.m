//
//  NSFKeyValueModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFKeyValueModel.h"

@interface NSFKeyValueModel()
@property (nonatomic, strong) NSString *UUID;

@end


@implementation NSFKeyValueModel

+ (instancetype)modelAtFile:(NSURL *)file
                      order:(NSUInteger)order
                        key:(NSString *)key
                      value:(NSString *)value
                   language:(NSFLanguage)language
{
    NSFKeyValueModel *model = [super modelAtFile:file order:order content:@""];
    model.key = key;
    model.value = value;
    model.language = language;
    
    return model;
}

- (instancetype)initWithFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content
{
    if (self = [super initWithFile:file order:order content:content])
    {
        @weakify(self);
        RAC(self, content) = [[RACObserve(self, key) merge:RACObserve(self, value)]
                              map:^id(id _) {
                                  @strongify(self);
                                  
                                  NSString *result = [NSString stringWithFormat:@"\"%@\" = \"%@\";", self.key, self.value];
                                  return result;
                              }];
    }
    
    return self;
}

- (NSString *)UUID
{
    if (!_UUID)
    {
        _UUID = [NSString stringWithFormat:@"%@_%@_%@", self.file, self.key, @(self.language)];
    }
    
    return _UUID;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key = %@, value = %@, language = %@", self.key, self.value, @(self.language)];
}

@end
