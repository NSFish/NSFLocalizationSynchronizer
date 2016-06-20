//
//  NSFStringsReduntantableIntermediaModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "NSFIntermediaModelProtocol.h"

@interface NSFStringsReduntantableIntermediaModel : NSObject<NSFIntermediaModel>
@property (nonatomic, copy) NSString *key;

- (NSString *)UUID;

@end
