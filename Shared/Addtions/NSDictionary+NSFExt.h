//
//  NSDictionary+NSFExt.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/25.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary(NSFExt)

- (void)nsf_writeToURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
