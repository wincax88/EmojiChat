//
//  TimerManager.h
//  XmppWhiteBoard
//
//  Created by michaelwong on 10/24/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpHandlerBase.h"

@protocol TimerManagerDelegate <NSObject>

// NSTimeInterval
- (void)onTimerFire:(NSNumber*)timeInterval;

@end

@interface TimerManager : HttpHandlerBase

@property (nonatomic, strong) NSNumber* timeInterval;

+ (TimerManager *) sharedInstance;

- (void)startTimer;
- (void)stopTimer;

- (void)startBackgroundTimer;
- (void)stopBackgroundTimer;

@end
