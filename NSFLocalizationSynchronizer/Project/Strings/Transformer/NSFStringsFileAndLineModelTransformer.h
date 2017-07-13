//
//  NSFStringsFileAndLineModelTransformer.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsLineModel;

@interface NSFStringsFileAndLineModelTransformer: NSObject

/**
 将strings文件转换成空白行、注释行和有用的key&value行
 */
+ (NSArray<__kindof NSFStringsLineModel *> *)lineModelsFrom:(NSURL *)stringsFileURL;

/**
 将空白行、注释行和key&value行拼接成strings文件的内容
 */
+ (NSString *)stringsFileContentFrom:(NSArray<__kindof NSFStringsLineModel *> *)lineModels;

@end

NS_ASSUME_NONNULL_END
