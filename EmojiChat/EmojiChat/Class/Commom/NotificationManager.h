//
//  NotificationManager.h
//  iParent
//
//  Created by michael on 20/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SUPPORT_IOS8 1

// recieve new quick message
#define PNS_QUICK_MESSAGE              @"PNS_QUICK_MESSAGE"

typedef void (^BPushRequestMethodBindBlock) (NSString *appId, NSString *channelId, NSString *userId);

@class PFUser;

@interface NotificationManager : NSObject

@property(copy) BPushRequestMethodBindBlock bindBlock;

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *userId;

+ (instancetype)sharedInstance;


- (void)registerDeviceToken:(NSData *)deviceToken;
- (void)handle4Application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
#if SUPPORT_IOS8
- (void)handle4application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
#endif
- (void)handle4application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)handle4application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)handle4application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler;


- (void)sendPush:(NSString*)alert to:(PFUser*)buddy;
- (void)sendPush:(NSString*)alert badge:(NSString*)badge sounds:(NSString*)sounds to:(PFUser*)buddy;
- (void)sendPush:(NSString*)alert badge:(NSString*)badge sounds:(NSString*)sounds category:(NSString*)category to:(PFUser*)buddy;


@end
