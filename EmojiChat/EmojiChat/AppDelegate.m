//
//  AppDelegate.m
//  EmojiChat
//
//  Created by michael on 8/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "JLNotificationPermission.h"
#import <SMS_SDK/SMS_SDK.h>

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#define SMS_SDK_APPKEY          @"7159ea8fc1b4"
#define SMS_SDK_APPSECRET       @"a0d873e2498c3bdec14d932646f4f24c"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable data sharing in main app.
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.leoedu.ichat"];
    // Setup Parse
    [Parse setApplicationId:@"f5Eiapb3uDqD6wODSmEYpbbpNvfpGTwjL5ePuXLh" clientKey:@"5JD23aAWSKvHhdjiRVuiPTO88QQ6TaTUjLfKoCpm"];

    //初始化应用，appKey和appSecret从后台申请得到
    [SMS_SDK registerApp:SMS_SDK_APPKEY withSecret:SMS_SDK_APPSECRET];

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [PFImageView class];
    //---------------------------------------------------------------------------------------------------------------------------------------------

    //
    [[ApplicationManager sharedManager] load];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.mainViewController = (MainViewController*)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    self.window.backgroundColor = [UIColor orangeColor];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    // Push
    [[ApplicationManager sharedManager].notificationManager handle4Application:application didFinishLaunchingWithOptions:launchOptions];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // check login state
    if ([PFUser currentUser] == nil)
    {
        // show login view
        [self.mainViewController loadLoginViewController];
    }
/*
    if ([ApplicationManager sharedManager].account.userid.intValue <= 0) {
        BOOL canAutoLogin = NO;
        if ([ApplicationManager sharedManager].localSettingData.enableAutoLogin) {
            // do auto login
            if ([self.mainViewController autoLogin]) {
                canAutoLogin = YES;
            }
        }
        if (!canAutoLogin) {
            // show login view
            [self.mainViewController loadLoginViewController];
        }
    }
    */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// This callback will be made upon calling -[UIApplication registerUserNotificationSettings:]. The settings the user has granted to the application will be passed in as the second argument.
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[ApplicationManager sharedManager].notificationManager handle4application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[ApplicationManager sharedManager].notificationManager handle4application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    // save tocken
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([newToken length] > 0) {
        [[ApplicationManager sharedManager].localSettingData setDeviceTocken:deviceToken];
        [[JLNotificationPermission sharedInstance] notificationResult:deviceToken error:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSData *deviceTocken = [ApplicationManager sharedManager].localSettingData.deviceTocken;
    if (deviceTocken && [deviceTocken length] > 0) {
        [[ApplicationManager sharedManager].notificationManager registerDeviceToken:deviceTocken];
        [[JLNotificationPermission sharedInstance] notificationResult:nil error:nil];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[ApplicationManager sharedManager].notificationManager handle4application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

// Called when your app has been activated by the user selecting an action from a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    [[ApplicationManager sharedManager].notificationManager handle4application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
}


@end
