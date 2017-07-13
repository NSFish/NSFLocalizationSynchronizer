//
//  NSFStringsSideCompareModel.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFStringsSideCompareModel.h"

@interface NSFStringsSideCompareModel()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURL *> *fileURLs;

@end


@implementation NSFStringsSideCompareModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.fileURLs = [NSMutableDictionary dictionary];
    }
    
    return self;
}

@end
