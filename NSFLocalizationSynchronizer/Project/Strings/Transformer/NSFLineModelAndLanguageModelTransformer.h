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
@class NSFStringsReduntantableIntermediaModel;

@interface NSFLineModelAndLanguageModelTransformer: NSObject

+ (NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModelsFrom:(NSArray<NSFKeyValueModel *> *)lineModels;
+ (NSArray<NSFKeyValueModel *> *)lineModelsFrom:(NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModels;

@end

NS_ASSUME_NONNULL_END
