//
//  NSFLocalizedStrinsExpert.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/11.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsCompareModel, NSFSourceCodeFragment;

/**
 所有工程端功能的入口
 */
@interface NSFProjectExpert: NSObject

- (instancetype)initWithProjectRoot:(NSURL *)projectRoot NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSArray<NSFSourceCodeFragment *> *)scanUnlocalizedStringInSourceCode;

#pragma mark - 比对
/**
 获取用于和语言包比较的中间models

 @param unified 是否使用统一的.strings文件来生成中间models
 */
- (NSArray<NSFStringsCompareModel *> *)compareModels:(BOOL)unified;

/**
 用与语言包比较过的中间models更新strings文件
 */
- (void)updateCompareModels:(NSArray<NSFStringsCompareModel *> *)compareModels;

@end

NS_ASSUME_NONNULL_END
