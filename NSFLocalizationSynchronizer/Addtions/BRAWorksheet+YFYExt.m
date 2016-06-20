//
//  BRAWorksheet+YFYExt.m
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/7.
//  Copyright © 2016年 乐星宇. All rights reserved.
//

#import "BRAWorksheet+YFYExt.h"

@implementation BRAWorksheet (YFYExt)

- (BRACell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col
{
    NSString *reference = [BRACell cellReferenceForColumnIndex:col andRowIndex:row];
    return [self cellForCellReference:reference];
}


@end
