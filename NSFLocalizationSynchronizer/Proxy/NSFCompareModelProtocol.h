//
//  NSFIntermediaModel.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/15.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 用于比较语言包和工程中文案的中间model都要实现此protocol
 */
@protocol NSFCompareModel<NSObject>
@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *translations;

- (NSString *)translation4Language:(NSFLanguage)language;
- (void)setTranslation:(NSString *)translation forLanguage:(NSFLanguage)language;

@optional
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
