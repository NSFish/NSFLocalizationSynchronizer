//
//  BLModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFCompareModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFLanguagePackLineModel: NSObject<NSFCompareModel>
@property (nonatomic, copy) NSString  *key;

/**
 目前语言包里还存在key为空的行，此时会用[NSUUID UUID]生成一个临时的key
 */
@property (nonatomic, assign) BOOL isKeyMadeup;

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy)   NSString  *platform;

@property (readonly) NSString *UUID;

@end

NS_ASSUME_NONNULL_END
