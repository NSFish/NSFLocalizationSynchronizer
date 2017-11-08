//
//  NSFParameters.m
//  NSFLocalizationSynchronizer
//
//  Created by 乐星宇 on 2017/7/28.
//  Copyright © 2017年 乐星宇. All rights reserved.
//

#import "NSFParameters.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation NSFParameters {
    CFDictionaryRef _signatures;
}
#pragma clang diagnostic pop

+ (instancetype)sharedInstance
{
    static NSFParameters *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSFParameters new];
    });
    
    return instance;
}

#pragma mark - Message forwarding
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    if (!_signatures)
    {
        _signatures = [self p_methodSignaturesForProtocol:@protocol(NSFParameters)];
    }
    
    NSMethodSignature *signature = CFDictionaryGetValue(_signatures, selector);
    
    //此处如果return nil, 则不会触发forwardInvocation
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *returnValue = NSStringFromSelector(invocation.selector);
    [invocation setReturnValue:&returnValue];
}

#pragma mark - Private
static CFMutableDictionaryRef _protocolCache = nil;
static OSSpinLock _lock = OS_SPINLOCK_INIT;

- (CFDictionaryRef)p_methodSignaturesForProtocol:(Protocol *)protocol
{
    OSSpinLockLock(&_lock);
    
    if (!_protocolCache)
    {
        _protocolCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    }
    
    CFDictionaryRef signatureCache = CFDictionaryGetValue(_protocolCache, (__bridge const void *)(protocol));
    if (!signatureCache)
    {
        // Add protocol methods + derived protocol method definitions into protocolCache.
        signatureCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        [self p_methodSignaturesForProtocol:protocol inDictionary:(CFMutableDictionaryRef)signatureCache];
        CFDictionarySetValue(_protocolCache, (__bridge const void *)(protocol), signatureCache);
        CFRelease(signatureCache);
    }
    
    OSSpinLockUnlock(&_lock);
    
    return signatureCache;
}

- (void)p_methodSignaturesForProtocol:(Protocol *)protocol
                         inDictionary:(CFMutableDictionaryRef)cache
{
    void (^enumerateRequiredMethods)(BOOL) = ^(BOOL isRequired) {
        unsigned int methodCount;
        struct objc_method_description *descr = protocol_copyMethodDescriptionList(protocol, isRequired, YES, &methodCount);
        for (NSUInteger idx = 0; idx < methodCount; idx++)
        {
            NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descr[idx].types];
            CFDictionarySetValue(cache, descr[idx].name, (__bridge const void *)(signature));
        }
        
        free(descr);
    };
    
    // We need to enumerate both required and optional protocol methods.
    enumerateRequiredMethods(NO);
    enumerateRequiredMethods(YES);
    
    // There might be sub-protocols we need to catch as well.
    unsigned int inheritedProtocolCount;
    Protocol *__unsafe_unretained* inheritedProtocols = protocol_copyProtocolList(protocol, &inheritedProtocolCount);
    for (NSUInteger idx = 0; idx < inheritedProtocolCount; idx++)
    {
        [self p_methodSignaturesForProtocol:inheritedProtocols[idx] inDictionary:cache];
    }
    
    free(inheritedProtocols);
}

@end
