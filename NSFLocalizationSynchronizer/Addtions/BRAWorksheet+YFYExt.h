//
//  BRAWorksheet+YFYExt.h
//  BidirectionLocalization
//
//  Created by 乐星宇 on 16/6/7.
//  Copyright © 2016年 乐星宇. All rights reserved.
//
#import <XlsxReaderWriter/XlsxReaderWriter.h>

@interface BRAWorksheet (YFYExt)

- (BRACell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col;


@end
