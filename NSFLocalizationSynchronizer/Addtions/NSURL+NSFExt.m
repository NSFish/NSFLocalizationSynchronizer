//
//  NSURL+NSFExt.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/24.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSURL+NSFExt.h"

@implementation NSURL(NSFExt)

- (NSString *)nsf_last2PathComponents
{
    NSArray<NSString *> *pathComponents = [[self pathComponents] subarrayWithRange:NSMakeRange(self.pathComponents.count - 2, 2)];
    
    return [[pathComponents firstObject] stringByAppendingPathComponent:[pathComponents lastObject]];
}

- (NSURL *)nsf_URLByReplacingLastPathComponentWith:(NSString *)component
{
    return [[self URLByDeletingLastPathComponent]
            URLByAppendingPathComponent:component];
}

@end
