//
//  NSFLocalizedStrinsExpert.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/11.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsIntermediaModel;

@interface NSFLocalizedStrinsExpert: NSObject

- (instancetype)initWithProjectRoot:(NSURL *)projectRoot NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSArray<NSURL *> *)stringFiles;

/**
 获取用于和语言包比较的中间models
 */
- (NSArray<NSFStringsIntermediaModel *> *)compareModels;

/**
 用与语言包比较过的中间models更新strings文件
 */
- (void)updateCompareModels:(NSArray<NSFStringsIntermediaModel *> *)compareModels;

@end

NS_ASSUME_NONNULL_END
