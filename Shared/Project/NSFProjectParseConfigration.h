//
//  NSFProjectParseConfigration.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/21.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NSFMainStringFileName;
extern NSString * const NSFSchoolVersionPrefix;

@interface NSFProjectParseConfigration: NSObject

+ (NSURL *)projectZh_HansLprojURLIn:(NSURL *)projectRoot;
+ (NSURL *)projectZh_HantLprojURLIn:(NSURL *)projectRoot;
+ (NSURL *)projectENLprojURLIn:(NSURL *)projectRoot;

+ (NSURL *)tempZh_HansLprojURL;
+ (NSURL *)tempZh_HantLprojURL;
+ (NSURL *)tempENLprojURL;

+ (NSURL *)tempFolder;

@end

NS_ASSUME_NONNULL_END
