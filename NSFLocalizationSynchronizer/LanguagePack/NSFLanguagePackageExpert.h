//
//  YFYLocalizedExcelFileHandler.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFLanguagePackLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFLanguagePackageExpert : NSObject

+ (instancetype)create:(NSURL *)URL;
+ (instancetype)load:(NSURL *)URL;

- (NSArray<NSFLanguagePackLineModel *> *)compareModels;
- (void)updateCompareModels:(NSArray<NSFLanguagePackLineModel *> *)compareModels;

@end

NS_ASSUME_NONNULL_END
