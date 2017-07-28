//
//  NSURL+NSFExt.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/24.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL(NSFExt)

- (NSString *)nsf_last2PathComponents;

- (NSURL *)nsf_URLByReplacingLastPathComponentWith:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
