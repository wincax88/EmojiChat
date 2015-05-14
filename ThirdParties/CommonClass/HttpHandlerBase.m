//
//  HttpHandlerBase.m
//  iTao
//
//  Created by michaelwong on 8/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "HttpHandlerBase.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface HttpHandlerBase()
{
    NSMutableDictionary     *delegates;
}

@end

@implementation HttpHandlerBase

- (id)init {
    self = [super init];
    if (self) {
        delegates = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)dealloc {
    delegates = nil;
}

#pragma mark - public

- (void)notifyDelegates:(id)object selector:(SEL)aSelector
{
    [self notifyDelegates:object selector:aSelector object:nil];
}

- (void)notifyDelegates:(id)object selector:(SEL)aSelector object:(id)object2
{
    // remove unused delegate
    NSMutableArray *removed = [[NSMutableArray alloc] init];
    for (NSString *key in delegates.allKeys) {
        NSDictionary *value = [delegates objectForKey:key];
        if ([[value objectForKey:@"removed"] intValue] > 0) {
            [removed addObject:key];
        }
    }
    for (NSString *key in removed) {
        [delegates removeObjectForKey:key];
    }
    [removed removeAllObjects];
    removed = nil;
    for (NSString *key in delegates.allKeys) {
        NSDictionary *value = [delegates objectForKey:key];
        id delegate = [value objectForKey:@"delegate"];
        if (delegate && [delegate respondsToSelector:aSelector]) {
            SuppressPerformSelectorLeakWarning(
                                               dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:aSelector withObject:object withObject:object2];
            });
                                               );
        }
    }
}

// add delegate
- (void)registerDelegate:(id)delegate
{
    NSString *key = [NSString stringWithFormat:@"%@", delegate];
    if ([delegates objectForKey:key] == nil) {
        [delegates setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0] , @"removed", delegate, @"delegate", nil] forKey:key];
    }
    else {
        [delegates setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0] , @"removed", delegate, @"delegate", nil] forKey:key];
    }
}

// remove delegate
- (void)unregisterDelegate:(id)delegate
{
    NSString *key = [NSString stringWithFormat:@"%@", delegate];
    NSDictionary *value = [delegates objectForKey:key];
    if (value) {
        [delegates setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1] , @"removed", delegate, @"delegate", nil] forKey:key];
    }
}

// remove delegate
- (void)unregisterDelegateForce:(id)delegate
{
    NSString *key = [NSString stringWithFormat:@"%@", delegate];
    if (key.length > 0) {
        [delegates removeObjectForKey:key];
    }
    
}

// remove all delegate
- (void)unregisterAllDelegates
{
    [delegates removeAllObjects];
}

@end
