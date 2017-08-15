//
//  NSFSourceCodeScanner.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/10.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFSourceCodeFragment: NSObject
@property (readonly) NSString *content;
@property (readonly) NSUInteger lineNumber;
@property (readonly) NSURL *fileURL;

+ (instancetype)instanceWithContent:(NSString *)content
                         lineNumber:(NSUInteger)lineNumber
                            fileURL:(NSURL *)fileURL;

- (NSDictionary *)toDictionary;

@end


@interface NSFSourceCodeScanner: NSObject

+ (NSArray<NSFSourceCodeFragment *> *)findNonLocalizedStringsIn:(NSURL *)projectURL;

@end

NS_ASSUME_NONNULL_END
