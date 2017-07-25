//
//  NSFStringsSideCompareModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/12.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFStringsCompareModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NSFStringsLanguageModel;

@interface NSFStringsSideCompareModel: NSFStringsCompareModel
@property (readonly) NSMutableDictionary<NSString *, NSURL *> *fileURLs;

@end

NS_ASSUME_NONNULL_END
