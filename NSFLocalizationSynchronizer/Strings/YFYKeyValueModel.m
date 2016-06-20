//
//  YFYKeyValueModel.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "YFYKeyValueModel.h"
#import <ReactiveCocoa.h>

@implementation YFYKeyValueModel

+ (instancetype)modelAtFile:(NSURL *)file order:(NSUInteger)order key:(NSString *)key value:(NSString *)value language:(NSString *)language
{
    YFYKeyValueModel *model = [super modelAtFile:file order:order content:nil];
    model.key = key;
    model.value = value;
    model.language = language;
    
    return model;
}

- (instancetype)initWithFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content
{
    if (self = [super initWithFile:file order:order content:content])
    {
        RAC(self, content) = [RACSignal combineLatest:@[RACObserve(self, key), RACObserve(self, value)] reduce:^id(NSString *key, NSString *value){
            return [NSString stringWithFormat:@"\"%@\" = \"%@\";", key, value];
        }];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key = %@, value = %@, language = %@", self.key, self.value, self.language];
}


@end
