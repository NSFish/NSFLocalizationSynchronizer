//
//  NSFLogger.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFLogger: NSObject

/**
 将Dictionary或Array转换成log文件

 @param object Dictionary或Array
 @param name log文件名，无须包含扩展名
 @return 若传入的object是指定类型且不为空，则返回log文件URL，否则返回nil
 */
+ (nullable NSURL *)logIfNeeded:(id)object withName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
