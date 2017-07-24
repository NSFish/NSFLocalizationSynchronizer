//
//  NSFStringFilesMixTransformer.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/20.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFStringFilesMixTransformer: NSObject

+ (NSArray<NSURL *> *)regenerateAllStringFilesIn:(NSURL *)projectRoot;

+ (NSString *)mixedStringFileContentFrom:(NSURL *)projectRoot;

@end

NS_ASSUME_NONNULL_END
