//
//  NSFKeyValueModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFKeyValueModel.h"
#import <ReactiveCocoa.h>

@implementation NSFKeyValueModel

+ (instancetype)modelAtFile:(NSURL *)file
                      order:(NSUInteger)order
                        key:(NSString *)key
                      value:(NSString *)value
                   language:(NSString *)language
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"key = %@, value = %@, language = %@", self.key, self.value, self.language];
}

@end
