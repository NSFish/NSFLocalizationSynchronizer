//
//  YFYLocalizedExcelFileHandler.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFLanguagePackLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFLanguagePackageExpert : NSObject

+ (instancetype)create:(NSURL *)URL;
+ (instancetype)load:(NSURL *)URL;

- (NSArray<NSFLanguagePackLineModel *> *)compareModels;
- (void)updateCompareModels:(NSArray<NSFLanguagePackLineModel *> *)compareModels;

/**
 扫描Key重复的行
 
 @return 有则返回log路径，没有则返回nil
 */
- (nullable NSDictionary *)scanKeyDuplicatedRows;

/**
 扫描翻译文案一致的多行(Key可能一致也可能不一致)
 */
- (nullable NSDictionary *)scanTranslationDuplicatedRows;

/**
 扫描简体中文文案一致，但其他翻译文案不一致的行
 */
- (NSDictionary *)scanZh_HansDuplicatedOnlyRows;

@end

NS_ASSUME_NONNULL_END
