//
//  NSFNotificationUserInfoProtocol.h
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 16/6/14.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  将Notification与其对应的特定的一个或多个数据类型绑定起来
 *  notification本身的name无法直接获取，而要通过特定的userInfo类型来获取
 */

@protocol NSFNotificationUserInfo <NSObject>

/**
 *  绑定的消息名称
 */
+ (NSString *)notificationName;

@end
