//
//  NSFSetting.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/8.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFSetting : NSObject

/**
 *  工程根目录
 */
+ (NSString *)projectRootFolderPath;
+ (void)setProjectRootFolderPath:(NSString *)path;

/**
 *  语言包文件路径
 */
+ (NSString *)languageFilePath;
+ (void)setLanguageFilePath:(NSString *)path;

/**
 *  生成xlsx文件、报错xml文件的统一目录路径，默认为桌面
 */
+ (NSString *)outputDirectoryPath;
+ (void)setOutputDirectoryPath:(NSString *)path;

@end
