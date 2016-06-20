//
//  BLModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFIntermediaModelProtocol.h"

@interface NSFLanguagePackLineModel : NSObject<NSFIntermediaModel>
@property (nonatomic, copy)   NSURL     *file;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy)   NSString *key;
@property (nonatomic, copy)   NSString *platform;

@end
