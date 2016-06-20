//
//  NSString+LineInStringsFile.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/3.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACTuple;

@interface NSString (LineInStringsFile)

- (NSString *)trim;

- (BOOL)isComment;
- (BOOL)isUsefulComment;

- (NSString *)possibleKey;

- (BOOL)isStartOfCStyleComment;
- (BOOL)isEndOfCStyleComment;

- (RACTuple *)keyAndValue;

- (NSString *)removeStringArrows;

- (NSString *)fixPlaceHolder;

@end
