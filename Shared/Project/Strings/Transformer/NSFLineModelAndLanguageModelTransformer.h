//
//  NSFLineModelAndLanguageModelTransformer.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFKeyValueModel;
@class NSFStringsLanguageModel;

@interface NSFLineModelAndLanguageModelTransformer: NSObject

+ (NSArray<NSFStringsLanguageModel *> *)languageModelsFrom:(NSArray<NSFKeyValueModel *> *)lineModels;
+ (NSArray<NSFKeyValueModel *> *)lineModelsFrom:(NSArray<NSFStringsLanguageModel *> *)languageModels;

@end

NS_ASSUME_NONNULL_END
