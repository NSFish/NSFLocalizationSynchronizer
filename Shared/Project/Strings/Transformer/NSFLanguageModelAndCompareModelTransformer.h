//
//  NSFLanguageModelAndCompareModelTransformer.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsLanguageModel;
@class NSFStringsCompareModel;

@interface NSFLanguageModelAndCompareModelTransformer: NSObject

+ (NSArray<NSFStringsCompareModel *> *)compareModelsFrom:(NSArray<NSFStringsLanguageModel *> *)languageModels;
+ (NSArray<NSFStringsLanguageModel *> *)languageModelsFrom:(NSArray<NSFStringsCompareModel *> *)compareModels;

@end

NS_ASSUME_NONNULL_END
