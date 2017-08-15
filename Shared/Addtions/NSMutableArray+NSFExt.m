//
//  NSMutableArray+NSFExt.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSMutableArray+NSFExt.h"

@implementation NSMutableArray(NSFExt)

- (void)nsf_addObjectIfNotNil:(nullable id)object
{
    if (object)
    {
        [self addObject:object];
    }
}

@end
