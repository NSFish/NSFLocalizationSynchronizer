//
//  NSFLogger.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFLogger.h"
#import "NSFSetting.h"

@implementation NSFLogger

+ (NSURL *)logIfNeeded:(id)object withName:(NSString *)name
{
    NSDictionary *dictionary = [NSDictionary safelyCast:object];
    NSArray *array = [NSArray safelyCast:object];
    
    NSUInteger count = dictionary ? dictionary.count : array.count;
    if (count == 0)
    {
        return nil;
    }
    
    NSString *key = dictionary ? @"Dictionary" : @"Array";
    NSDictionary *log = @{@"Count": @(count),
                          key: object};
    
    NSURL *URL = [[[NSFSetting logFolder]
                   URLByAppendingPathComponent:[name stringByDeletingPathExtension]]
                  URLByAppendingPathExtension:@"json"];
    [log nsf_writeToURL:URL];
    
    return URL;
}

@end
