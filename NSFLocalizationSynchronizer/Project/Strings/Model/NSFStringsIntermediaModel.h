//
//  NSFCompoundIntermediaModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFIntermediaModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFStringsIntermediaModel: NSObject<NSFIntermediaModel>
@property (readonly) NSMutableArray<NSString *> *keys;

@end

NS_ASSUME_NONNULL_END
