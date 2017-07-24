//
//  NSFileManager+NSFExt.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/20.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager(NSFExt)

+ (NSURL *)nsf_desktopURL;

+ (NSArray<NSURL *> *)nsf_contentsOfDirectoryAtURL:(NSURL *)folderURL
                                         thatMatch:(nullable BOOL(^)(NSURL *URL))match;

+ (NSArray<NSURL *> *)nsf_filesThatMatch:(nullable BOOL(^)(NSURL *))fileMatched
                                inFolder:(NSURL *)folderURL
                ignoreSubFolderThatMatch:(nullable BOOL(^)(NSURL *))folderMatched;

+ (void)nsf_convertContentEncodingOfFileAt:(NSURL *)URL encoding:(NSStringEncoding)encoding;

+ (BOOL)nsf_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL;
+ (BOOL)nsf_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL;

@end

NS_ASSUME_NONNULL_END
