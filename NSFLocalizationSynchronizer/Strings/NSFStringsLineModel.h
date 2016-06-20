//
//  BLIntermediaModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFStringsLineModel : NSObject
@property (nonatomic, copy)   NSURL     *file;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, copy)   NSString  *content;

+ (instancetype)modelAtFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content;
- (instancetype)initWithFile:(NSURL *)file order:(NSUInteger)order content:(NSString *)content;

@end
