//
//  NSFLanguageModelAndCompareModelTransformer.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsReduntantableIntermediaModel;
@class NSFStringsIntermediaModel;

@interface NSFLanguageModelAndCompareModelTransformer: NSObject

+ (NSArray<NSFStringsIntermediaModel *> *)compareModelsFrom:(NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModels;
+ (NSArray<NSFStringsReduntantableIntermediaModel *> *)languageModelsFrom:(NSArray<NSFStringsIntermediaModel *> *)compareModels;

@end

NS_ASSUME_NONNULL_END
