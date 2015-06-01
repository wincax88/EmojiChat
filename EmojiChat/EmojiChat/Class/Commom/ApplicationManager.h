//
//  ApplicationManager.h
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBAudioManager.h"
#import "LocalSettingData.h"
//#import "HttpClientHandler.h"
//#import "ManualDownloadManager.h"
//#import "ManualUplaodManager.h"
#import "TimerManager.h"
#import "NotificationManager.h"
#import "ConfigureObject.h"
#import "ChatBuddy.h"
//#import "XmppManager4Chat.h"
#import "AccountObject.h"
#import "FriendObject.h"

@class PFUser;

@interface ApplicationManager : NSObject

#pragma mark - user data
// local settings
@property(nonatomic, retain) LocalSettingData       *localSettingData;

#pragma mark - audio engin
// sound manager
@property(nonatomic, retain) YBAudioManager         *soundManager;

#pragma mark - networking
// http handler
//@property(nonatomic, retain) HttpClientHandler      *httpClientHandler;
// manual download manager
//@property(nonatomic, retain) ManualDownloadManager  *manualDownloadManager;
// manual upload manager
//@property(nonatomic, retain) ManualUplaodManager    *manualUplaodManager;
// XmppManager for chat
//@property(nonatomic, retain) XmppManager4Chat       *xmppManager4Chat;
// NotificationManager
@property(nonatomic, retain) NotificationManager    *notificationManager;

#pragma mark - timer
@property(nonatomic, retain) TimerManager           *timerManager;


#pragma mark - user data
//@property(nonatomic, strong) Student                *student;
@property(nonatomic, strong) ConfigureObject        *configureObject;
@property(nonatomic, strong) NSMutableArray         *defaultQuickMessageArray;
// friends
//@property(nonatomic, strong) NSMutableArray         *friendArray;

@property(nonatomic ,assign) BOOL isLogin;
@property(nonatomic, strong) AccountObject          *account;

// my invite users
@property(nonatomic, strong) NSMutableArray         *inviteUserArray;

// my friend list
//@property(nonatomic, strong) NSMutableArray         *chatBuddyList;

// my confirm list
@property(nonatomic, strong) NSMutableArray         *confirmList;

// quick chat - answer - audio
@property(nonatomic, strong) NSMutableArray         *quickChatGroups;

// need quick answer list
@property(nonatomic, strong) NSMutableArray         *quickAnswerList;

// friend list
@property(nonatomic, strong) NSMutableArray         *friendList; // PFUser list

#pragma mark - method
+ (ApplicationManager *)sharedManager;

- (void)load;
- (void)unload;
- (void)clean4Logout;
//

// save account and password
- (void)saveAccount:(NSString*)account password:(NSString*)password;

- (void)removeQuickChat:(int)index;
- (void)exchangeQuickChatFrom:(int)sourceIndex to:(int)destinationIndex;
- (void)addQuickChat:(NSString*)message after:(int)index;

@end
