//
//  BLModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFIntermediaModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFLanguagePackLineModel: NSObject<NSFIntermediaModel>
@property (nonatomic, copy)   NSURL     *file;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy)   NSString  *key;
@property (nonatomic, copy)   NSString  *platform;

@end


@interface NSString(LanguagePack)

/**
 兼容Android写入的文案，移除文案前后的<string></string>
 */
- (NSString *)removeStringArrows;

@end

NS_ASSUME_NONNULL_END
