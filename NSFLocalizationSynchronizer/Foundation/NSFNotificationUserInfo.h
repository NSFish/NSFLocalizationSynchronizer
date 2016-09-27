//
//  NSFNotificationUserInfo.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/14.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFNotificationUserInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新完工程中所有.strings文件的文案的消息附带的数据
 */
@interface NSFDidUpdateProjectNotificationUserInfo : NSDictionary<NSFNotificationUserInfo>
@property (nonatomic, assign, readonly) NSUInteger updateCount;
@property (nonatomic, copy, readonly)   NSString   *uselessLogFilePath;
@property (nonatomic, copy, readonly)   NSString   *multipleMatchXmlPath;

+ (instancetype)userInfoWithUpdateCount:(NSUInteger)updateCount
                     uselessLogFilePath:(NSString *)uselessLogFilePath
                   multipleMatchXmlPath:(nullable NSString *)multipleMatchXmlPath;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 *  更新完语言包中所有文案的Key的消息附带的数据
 */
@interface NSFDidUpdateLanguageFileNotificationUserInfo : NSDictionary<NSFNotificationUserInfo>
@property (nonatomic, assign, readonly) NSUInteger updateCount;
@property (nonatomic, copy, readonly)   NSString   *uselessLogFilePath;
@property (nonatomic, copy, readonly)   NSString   *duplicatedLogFilePath;

+ (instancetype)userInfoWithUpdateCount:(NSUInteger)updateCount
                     uselessLogFilePath:(NSString *)uselessLogFilePath
                  duplicatedLogFilePath:(nullable NSString *)duplicatedLogFilePath;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
