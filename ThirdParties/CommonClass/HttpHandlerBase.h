//
//  HttpHandlerBase.h
//  iTao
//
//  Created by michaelwong on 8/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpHandlerBase : NSObject
// add delegate
- (void)registerDelegate:(id)delegate;
// remove delegate
- (void)unregisterDelegate:(id)delegate;
// remove delegate
- (void)unregisterDelegateForce:(id)delegate;
// remove all delegate
- (void)unregisterAllDelegates;
// notify delegates
- (void)notifyDelegates:(id)object selector:(SEL)aSelector;
- (void)notifyDelegates:(id)object selector:(SEL)aSelector object:(id)object2;

@end
