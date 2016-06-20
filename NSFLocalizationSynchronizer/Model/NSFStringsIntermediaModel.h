//
//  NSFCompoundIntermediaModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFLanguagePackIntermediaModel.h"

@interface NSFStringsIntermediaModel : NSObject<NSFIntermediaModel>
@property (nonatomic, copy, readonly) NSArray<NSString *> *keys;

- (void)addKey:(NSString *)key;

@end
