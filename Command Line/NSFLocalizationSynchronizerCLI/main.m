//
//  main.m
//  NSFLocalizationSynchronizerCLI
//
//  Created by 乐星宇 on 2017/8/14.
//  Copyright © 2017年 FangCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFLocalizationProxy.h"
#import "NSFSetting.h"
#import "NSFProjectParseConfigration.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc == 1)
        {
            printf("Usage: nsflocalizer -l /Path/to/语言包 -p /Path/to/工程根目录");
            return 0;
        }
        
        NSString *languagePackPath = nil;
        NSString *projectRoot = nil;
                                 
        for (NSUInteger i = 0; i < argc; i++)
        {
            NSString *string = [NSString stringWithUTF8String:argv[i]];
            if ([string isEqualToString:@"-l"]
                && (i + 1 < argc))
            {
                languagePackPath = [NSString stringWithUTF8String:argv[i + 1]];
            }
            else if ([string isEqualToString:@"-p"]
                     && (i + 1 < argc))
            {
                projectRoot = [NSString stringWithUTF8String:argv[i + 1]];
            }
        }
        
        BOOL inputInvalid = NO;
        if (!languagePackPath)
        {
            inputInvalid = YES;
            printf("请输入语言包路径");
        }
        else if (!projectRoot)
        {
            inputInvalid = YES;
            printf("请输入工程根目录");
        }
        
        if (inputInvalid)
        {
            return 0;
        }
        
        [NSFSetting setLanguageFilePath:languagePackPath];
        [NSFSetting setProjectRootFolderPath:projectRoot];
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[NSFLocalizationProxy updateStringsFiles:NO] subscribeNext:^(NSURL *log) {
            if (log)
            {
                printf("发现工程中存在语言包里没有的文案，log位于%s", [[log path] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    return 0;
}
