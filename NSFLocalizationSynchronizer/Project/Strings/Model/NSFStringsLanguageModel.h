//
//  NSFStringsLanguageModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFIntermediaModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class NSFKeyValueModel;

/**
 将同名的、不同语言的.strings文件的lineModels整合起来
 同名但实际上不属于同一个多语言bundle的会被区分开，比如Main App和Extension的info.plist对应的.strings文件是分开整合的
 */
@interface NSFStringsLanguageModel: NSObject<NSFIntermediaModel>
@property (nonatomic, copy) NSString *key;

/**
 .strings文件的不同语言版本的路径
 */
@property (readonly) NSMutableDictionary<NSString *, NSURL *> *fileURLs;

/**
 根据简体中文、繁体中文和英文三种翻译文案生成key
 */
- (NSString *)UUID;

/**
 将传入的lineModel的翻译文案填充到对应语言的property中
 */
- (void)integrate:(NSFKeyValueModel *)keyValueModel;

@end

NS_ASSUME_NONNULL_END
