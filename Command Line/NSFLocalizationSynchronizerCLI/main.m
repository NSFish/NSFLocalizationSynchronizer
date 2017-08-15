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
            NSLog(@"请输入语言包路径");
        }
        else if (!projectRoot)
        {
            inputInvalid = YES;
            NSLog(@"请输入工程根目录");
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
                NSLog(@"发现工程中存在语言包里没有的文案，log位于%@", [log path]);
            }
            
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    return 0;
}
