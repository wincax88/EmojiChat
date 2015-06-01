//
//  NotificationManager.m
//  iParent
//
//  Created by michael on 20/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "NotificationManager.h"
#import "NotificationObject.h"
#import "ApplicationManager.h"

#import <Parse/Parse.h>
#import "AppConstant.h"


NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const kNotificationActionCancel = @"kNotificationActionCancel";
NSString * const kNotificationActionAnswer = @"kNotificationActionAnswer";

@interface NotificationManager()
{
    
}

@end

static id _sharedInstance;

@implementation NotificationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - private
/*
aps =     {
    alert = "peter: \Ud83c\Udf92";
    badge = 4;
    category = ACTIONABLE;
    sound = "hello.wav";
};
senderid = 13564417734;
*/
- (NotificationObject*)parseRemoteUserInfo:(NSDictionary*)userInfo
{
    NotificationObject *notification = [[NotificationObject alloc] init];
    notification.senderid = [userInfo objectForKey:@"senderid"];
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    notification.message = [aps objectForKey:@"alert"];
    notification.sound = [aps objectForKey:@"sound"];
    notification.timestamp = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
    /*
    [[ApplicationManager sharedManager].quickAnswerList addObject:notification];
    
    NSMutableDictionary *applicationState = [[NSMutableDictionary alloc] init];
    [applicationState setObject:[NSNumber numberWithInt:[UIApplication sharedApplication].applicationState] forKey:@"applicationState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PNS_QUICK_MESSAGE object:nil userInfo:applicationState];
     */
    return notification;
}

- (void)parseRemoteNotification:(NSDictionary*)userInfo application:(UIApplication *)application fromLaunch:(BOOL)fromLaunch
{
    NSNumber *message_id = [userInfo objectForKey:@"message_id"];
    NSMutableDictionary *message_content = [[NSMutableDictionary alloc] initWithDictionary:[userInfo objectForKey:@"message_content"] copyItems:YES];
    [message_content setObject:[NSNumber numberWithInt:application.applicationState] forKey:@"applicationState"];
    if (1/*fromLaunch || application.applicationState == UIApplicationStateActive*/) {
        // send notification to UI
        if (message_id.intValue == 0) {
//            NSParameterAssert(false);
            /*
             aps =     {
             alert = "\U6765\U6211\U529e\U516c\U5ba4\U4e00\U4e0b";
             badge = 0;
             sound = "come_office.wav";
             };
             "message_content" =     {
             senderid = 60023;
             };
             "message_id" = 0;
             */
            NSString *senderid = [message_content objectForKey:@"senderid"];
            NSDictionary *aps = [userInfo objectForKey:@"aps"];
            NSString *message = [aps objectForKey:@"alert"];
            NSString *sound = [aps objectForKey:@"sound"];
            if (senderid.intValue > 0 && message.length > 0) {
                NotificationObject *notification = [[NotificationObject alloc] init];
                notification.senderid = senderid;
                notification.message = message;
                notification.sound = sound;
                notification.timestamp = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
                [[ApplicationManager sharedManager].quickAnswerList addObject:notification];
                [[NSNotificationCenter defaultCenter] postNotificationName:PNS_QUICK_MESSAGE object:nil userInfo:message_content];
            }
        }
        else {
            
        }
        //
    }
}

- (void)parseLocalNotification:(UILocalNotification*)localNotif
{
    
}

#pragma mark - public
- (void)handle4Application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    
    [application setApplicationIconBadgeNumber:0];
    
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"忽略"];
        [action1 setIdentifier:kNotificationActionCancel];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:kNotificationActionAnswer];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[action1, action2]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                        UIUserNotificationTypeSound|
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types
                                                     categories:categories];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    if (launchOptions != nil)
    {
        // for remote notification
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            // parse remote notification
            [self parseRemoteNotification:dictionary application:application fromLaunch:YES];
        }
        // for local notification
        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotif) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            // parse local notification
        }
    }
}

#if SUPPORT_IOS8
- (void)handle4application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)registerDeviceToken:(NSData *)deviceToken
{
//    [BPush registerDeviceToken: deviceToken];
}

- (void)handle4application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
//    currentInstallation.channels = @[@"global", currentInstallation.installationId];
    [currentInstallation saveInBackground];
}

- (void)handle4application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
    if ([PFUser currentUser] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseRemoteNotification:userInfo application:application fromLaunch:NO];
        });
        [application setApplicationIconBadgeNumber:0];
    }
}

- (void)handle4application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:kNotificationActionCancel]) {
        
        NSLog(@"You chose action cancel.");
    }
    else if ([identifier isEqualToString:kNotificationActionAnswer]) {
        
        NSLog(@"You chose action answer.");
        // send answer to partner
        NotificationObject *notification = [self parseRemoteUserInfo:userInfo];
        NSString *senderId = notification.senderid;
        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_PHONE equalTo:senderId];
        PFUser *sender = (PFUser*)[query getFirstObject];
        if (sender) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendPush:@"😊" to:sender];
            });
        }
        else {
            NSLog(@"can not find : %@", senderId);
        }
    }
    else {
        NSParameterAssert(false);
    }
    if (completionHandler) {
        
        completionHandler();
    }
    
}

- (void)sendPush:(NSString*)alert to:(PFUser*)buddy
{
    [self sendPush:alert badge:@"Increment" sounds:@"hello.wav" category:NotificationCategoryIdent to:buddy];
}

- (void)sendPush:(NSString*)alert  badge:(NSString*)badge sounds:(NSString*)sounds to:(PFUser*)buddy
{
    [self sendPush:alert badge:badge sounds:sounds category:NotificationCategoryIdent to:buddy];
}

- (void)sendPush:(NSString*)alert  badge:(NSString*)badge sounds:(NSString*)sounds category:(NSString*)category to:(PFUser*)buddy {
    PFUser *user = [PFUser currentUser];
    NSString *message = [NSString stringWithFormat:@"%@: %@", user[PF_USER_NICKNAME], alert];
    NSDictionary *data = @{
                           @"alert" : message,
                           @"badge" : badge,
                           @"sound" : sounds,
                           @"category" :category,
                           @"senderid" : user[PF_USER_PHONE]
                           };
    
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:buddy];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:data];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [push sendPushInBackgroundWithBlock:^ (BOOL succeeded, NSError *error) {
            if (!succeeded || error) {
                NSLog(@"sendPushInBackgroundWithBlock error = %@", error);
            }
            else {
                NSLog(@"sendPushInBackgroundWithBlock OK");
            }
        }];
    }
    else {
        NSError *error;
        [push sendPush:&error];
        if (error) {
            NSLog(@"sendPush error = %@", error);
        }
        else {
            NSLog(@"sendPush OK");
        }
    }
}



@end
