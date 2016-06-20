//
//  YFYLocalizedExcelFileHandler.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFLanguagePackLineModel.h"

@interface YFYLocalizedExcelFileHandler : NSObject

+ (instancetype)create:(NSURL *)URL;
+ (instancetype)load:(NSURL *)URL;

- (NSArray<NSFLanguagePackLineModel *> *)intermediaModels;
- (void)writeToFile:(NSArray<NSFLanguagePackLineModel *> *)intermediaModels;

@end
