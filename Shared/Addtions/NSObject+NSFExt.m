//
//  NSObject+YFYExt.m
//  Cooloffice
//
//  Created by le xingyu on 16/2/2.
//  Copyright © 2016年 lxzhh. All rights reserved.
//

#import "NSObject+NSFExt.h"

@implementation NSObject(NSFExt)

+ (instancetype)safelyCast:(NSObject *)object
{
    if ([object isKindOfClass:[self class]])
    {
        return object;
    }
    
    return nil;
}


@end
