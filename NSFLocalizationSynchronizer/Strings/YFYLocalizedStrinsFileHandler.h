//
//  YFYLocalizedStrinsFileHandler.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFStringsIntermediaModel.h"

@interface YFYLocalizedStrinsFileHandler : NSObject

- (instancetype)initWithProjectRootDirectory:(NSURL *)projectRootDirectory;

- (NSArray<NSFStringsIntermediaModel *> *)intermediaModels;
- (void)overrideStringFiles:(NSArray<NSFStringsIntermediaModel *> *)intermediaModels;

@end
