//
//  NSFileManager+NSFExt.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/20.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFileManager+NSFExt.h"

@implementation NSFileManager(NSFExt)

+ (NSArray<NSURL *> *)nsf_contentsOfDirectoryAtURL:(NSURL *)folderURL
                                         thatMatch:(nullable BOOL(^)(NSURL *URL))match
{
    NSArray<NSURL *> *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folderURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    if (match)
    {
        return [fileURLs.rac_sequence filter:^BOOL(NSURL *URL) {
            return match(URL);
        }].array;
    }
    
    return fileURLs;
}

+ (NSArray<NSURL *> *)nsf_filesThatMatch:(BOOL(^)(NSURL *))fileMatched
                                inFolder:(NSURL *)folderURL
                ignoreSubFolderThatMatch:(BOOL(^)(NSURL *))folderMatched
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:folderURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             return YES;
                                         }];
    
    NSMutableArray *fileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator)
    {
        NSString *filename = nil;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if ([isDirectory boolValue])
        {
            if (folderMatched && folderMatched(fileURL))
            {
                [enumerator skipDescendants];
            }
            
            continue;
        }
        else
        {
            if (!fileMatched
                || fileMatched(fileURL))
            {
                [fileURLs addObject:fileURL];
            }
        }
    }
    
    return fileURLs;
}

+ (void)nsf_convertContentEncodingOfFileAt:(NSURL *)URL encoding:(NSStringEncoding)encoding
{
    NSString *content = [[NSString alloc] initWithContentsOfURL:URL usedEncoding:nil error:nil];
    [content writeToURL:URL atomically:YES encoding:encoding error:nil];
}

+ (BOOL)nsf_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL
{
    return [[NSFileManager defaultManager] replaceItemAtURL:originalItemURL
                                              withItemAtURL:newItemURL
                                             backupItemName:nil
                                                    options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                           resultingItemURL:nil
                                                      error:nil];
}

+ (BOOL)nsf_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dstURL path] isDirectory:nil])
    {
        [[NSFileManager defaultManager] removeItemAtURL:dstURL error:nil];
    }
    
    return [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:dstURL error:nil];
}

@end
