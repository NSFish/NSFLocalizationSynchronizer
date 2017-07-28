//
//  NSFParameters.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define P [NSFParameters sharedInstance]

@protocol NSFParameters<NSObject>

- (NSString *)path;
- (NSString *)paths;

@end


@interface NSFParameters: NSObject<NSFParameters>

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
