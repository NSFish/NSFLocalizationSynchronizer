//
//  NSLocalizationStrategy.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFLocalizationProxy: NSObject

#pragma mark - 语言包
+ (RACSignal<NSArray<NSURL *> *> *)scanLanguagePack;

#pragma mark - Project
/**
 扫描工程源码中未国际化的字符串
 */
+ (RACSignal *)scanUnlocalizedStringInSourceCode;

#pragma mark - 同步
/**
 根据语言包的内容更新工程中的.strings文件

 @param strict 是否使用严格模式，在严格模式下仅根据key进行匹配，否则会在找不到key时将简体中文也纳入考虑
 @return RACTuple(updatedCount, mismatchedStringModels)
 */
+ (RACSignal *)updateStringsFiles:(BOOL)strict;

/**
 将工程中的.strings文件转换成一个统一的.strings文件，再执行updateStringsFiles的逻辑
 */
+ (RACSignal *)updateUnifiedStringFiles:(BOOL)strict;

@end

NS_ASSUME_NONNULL_END
