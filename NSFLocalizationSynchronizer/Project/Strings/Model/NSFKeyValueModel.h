//
//  NSFKeyValueModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFStringsLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFKeyValueModel: NSFStringsLineModel
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *language;

+ (instancetype)modelAtFile:(NSURL *)file
                      order:(NSUInteger)order
                        key:(NSString *)key
                      value:(NSString *)value
                   language:(NSString *)language;

+ (instancetype)modelAtFile:(NSURL *)file
                    content:(NSString *)content NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
