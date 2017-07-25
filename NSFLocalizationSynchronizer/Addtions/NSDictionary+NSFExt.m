//
//  NSDictionary+NSFExt.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/25.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSDictionary+NSFExt.h"
#import <XMLDictionary.h>

@implementation NSDictionary(NSFExt)

- (void)nsf_writeToURL:(NSURL *)URL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:[URL path] contents:nil attributes:nil];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:[self XMLString] options:0 error:nil];
    NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    [xmlData writeToURL:URL atomically:YES];
}

@end
