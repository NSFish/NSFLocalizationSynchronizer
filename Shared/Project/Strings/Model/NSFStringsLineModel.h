//
//  BLIntermediaModel.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/2.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define NSFBlankLineModel NSFStringsLineModel
#define NSFCommentLineModel NSFStringsLineModel

@interface NSFStringsLineModel : NSObject
@property (nonatomic, copy)   NSURL     *file;
@property (nonatomic, assign) NSUInteger order;
@property (nonatomic, copy)   NSString  *content;

+ (instancetype)modelAtFile:(NSURL *)file
                      order:(NSUInteger)order
                    content:(NSString *)content;

- (instancetype)initWithFile:(NSURL *)file
                       order:(NSUInteger)order
                     content:(NSString *)content NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


#pragma mark - String Extension
@class RACTuple;

@interface NSString(LineInStringsFile)

- (NSString *)trim;

- (BOOL)isComment;
- (BOOL)isUsefulComment;

- (NSString *)possibleKey;

- (BOOL)isStartOfCStyleCommentBlock;
- (BOOL)isEndOfCStyleCommentBlock;

- (RACTuple *)keyAndValue;

- (NSString *)fixPlaceHolder;

@end

NS_ASSUME_NONNULL_END
