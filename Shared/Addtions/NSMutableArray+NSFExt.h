//
//  NSMutableArray+NSFExt.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray(NSFExt)

- (void)nsf_addObjectIfNotNil:(nullable id)object;

@end

NS_ASSUME_NONNULL_END
