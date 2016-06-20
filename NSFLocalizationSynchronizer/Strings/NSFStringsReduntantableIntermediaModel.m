//
//  NSFStringsReduntantableIntermediaModel.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsReduntantableIntermediaModel.h"

@implementation NSFStringsReduntantableIntermediaModel
@synthesize zh_Hans, zh_Hant, en;

- (NSString *)UUID
{
    return [NSString stringWithFormat:@"%@_%@_%@", zh_Hans, zh_Hant, en];
}

@end
