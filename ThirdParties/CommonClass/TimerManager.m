//
//  TimerManager.m
//  XmppWhiteBoard
//
//  Created by michaelwong on 10/24/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "TimerManager.h"
#import "MSWeakTimer.h"

static const char *YBTimerManagerQueueContext = "YBTimerManagerQueueContext";

@interface TimerManager()

@property (strong, nonatomic) MSWeakTimer *timer;
@property (strong, nonatomic) MSWeakTimer *backgroundTimer;

@property (strong, nonatomic) dispatch_queue_t privateQueue;

@end

@implementation TimerManager

+ (TimerManager *) sharedInstance
{
    static TimerManager *sharedTimerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimerManager = [[TimerManager alloc] init];
    });
    return sharedTimerManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _timeInterval = [NSNumber numberWithDouble:0.5f];
    }
    return self;
}

- (void)dealloc
{
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
}

- (void)startTimer
{
    if (_timer) {
        return;
    }
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:self.timeInterval.doubleValue
                                                      target:self
                                                    selector:@selector(mainThreadTimerDidFire:)
                                                    userInfo:nil
                                                     repeats:YES
                                               dispatchQueue:dispatch_get_main_queue()];

}

- (void)stopTimer
{
    [self.timer invalidate];
    _timer = nil;
}

- (void)startBackgroundTimer
{
    if (_backgroundTimer) {
        return;
    }
    self.privateQueue = dispatch_queue_create("com.liyou.private_queue", DISPATCH_QUEUE_CONCURRENT);
    self.backgroundTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.timeInterval.doubleValue
                                                                target:self
                                                              selector:@selector(backgroundTimerDidFire)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:self.privateQueue];
    
    dispatch_queue_set_specific(self.privateQueue, (__bridge const void *)(self), (void *)YBTimerManagerQueueContext, NULL);
}
- (void)stopBackgroundTimer
{
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
}

#pragma mark - MSWeakTimerDelegate

- (void)mainThreadTimerDidFire:(MSWeakTimer *)timer
{
    NSAssert([NSThread isMainThread], @"This should be called from the main thread");
    NSNumber *data = self.timeInterval;
    [self notifyDelegates:data selector:@selector(onTimerFire:)];
}

#pragma mark -

- (void)backgroundTimerDidFire
{
    NSAssert(![NSThread isMainThread], @"This shouldn't be called from the main thread");
    
    const BOOL calledInPrivateQueue = dispatch_queue_get_specific(self.privateQueue, (__bridge const void *)(self)) == YBTimerManagerQueueContext;
    NSAssert(calledInPrivateQueue, @"This should be called on the provided queue");
    [self notifyDelegates:self.timeInterval selector:@selector(onTimerFire:)];
}

@end
