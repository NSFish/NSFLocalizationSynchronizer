//
//  NSFIntermediaModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSFIntermediaModel <NSObject>
@property (nonatomic, copy) NSString *zh_Hans;
@property (nonatomic, copy) NSString *zh_Hant;
@property (nonatomic, copy) NSString *en;

@optional
- (NSDictionary *)toDictionary;

@end
