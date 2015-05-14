//
//  ApplicationManager.m
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ApplicationManager.h"
#import "YBUtility.h"
#import "HttpClient.h"
#import "MD5.h"

#define DEFAULT_QUICK_CHAT_FILE     @"QuickChat.plist"

@implementation ApplicationManager

static ApplicationManager *sharedAppManager = nil;

+ (ApplicationManager *)sharedManager {
    @synchronized(self) {
        if (sharedAppManager == nil) {
            sharedAppManager = [[self alloc] init];
        }
    }
    return sharedAppManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _soundManager           = [[YBAudioManager alloc] init];
        _localSettingData       = [[LocalSettingData alloc] init];
        _httpClientHandler      = [[HttpClientHandler alloc] init];
        _manualDownloadManager  = [ManualDownloadManager sharedInstance];
        
        _manualUplaodManager    = [ManualUplaodManager sharedInstance];
        _manualUplaodManager.publicUploadTokenUrl = GET_PUBLIC_UPLOAD_TOKEN_URL;
        
        _timerManager           = [TimerManager sharedInstance];
//        _xmppManager4Chat       = [[XmppManager4Chat alloc] init];
        _notificationManager    = [NotificationManager sharedInstance];
        _defaultQuickMessageArray = [[NSMutableArray alloc] init];
        _account                = [[AccountObject alloc] init];
//        _friendArray            = [[NSMutableArray alloc] init];
        _inviteUserArray        = [[NSMutableArray alloc] init];
        _confirmList            = [[NSMutableArray alloc] init];
        
        _configureObject        = [_localSettingData getConfigure];
        if (_configureObject) {
            _configureObject.update = [NSNumber numberWithBool:NO];
        }
        else {
            _configureObject    = [[ConfigureObject alloc] init];
        }
//        _chatBuddyList          = [[NSMutableArray alloc] init];
        
        _isLogin                = NO;
        
        _quickAnswerList        = [[NSMutableArray alloc] init];
        
        _quickChatGroups        = [[NSMutableArray alloc] init];
        NSString *source = [[NSBundle mainBundle] pathForResource:@"DefaultChatMessage" ofType:@"plist"];
        [_quickChatGroups addObjectsFromArray:[NSArray arrayWithContentsOfFile:source]];
        
        _friendList             = [[NSMutableArray alloc] init];
        
        [self loadDefaultQuickMessageArray];
    }
    return self;
}

- (void)dealloc {
    _soundManager           = nil;
    _localSettingData       = nil;
    _httpClientHandler      = nil;
    _manualDownloadManager  = nil;
    _manualUplaodManager    = nil;
    _timerManager           = nil;
//    _xmppManager4Chat       = nil;
    _notificationManager    = nil;
    _configureObject        = nil;
//    _chatBuddyList          = nil;
    _account                = nil;
    _confirmList            = nil;
    _inviteUserArray        = nil;
}

- (void)load
{
    [_timerManager startBackgroundTimer];
//    [_xmppManager4Chat setupStream];
    
    __weak __typeof(self) weakSelf = self;
    _notificationManager.bindBlock = ^(NSString *appId, NSString *channelId, NSString *userId) {
        [weakSelf.localSettingData setBPushWithAppId:appId userId:userId channelId:channelId];
    };

}

- (void)unload
{
    [_timerManager stopBackgroundTimer];
}

- (void)clean4Logout {
//    [_xmppManager4Chat disconnect];
//    _chatBuddyList          = nil;
    _account                = nil;
    _confirmList            = nil;
    _inviteUserArray        = nil;
    _quickAnswerList        = nil;
    
//    _chatBuddyList          = [[NSMutableArray alloc] init];
    _defaultQuickMessageArray = nil;
    _account                = [[AccountObject alloc] init];
    _confirmList            = [[NSMutableArray alloc] init];
    _inviteUserArray        = [[NSMutableArray alloc] init];
    _quickAnswerList        = [[NSMutableArray alloc] init];
    
    [self loadDefaultQuickMessageArray];
}

// save account and password
- (void)saveAccount:(NSString*)account password:(NSString*)password
{
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    
    [YBUtility savePassword:md5Password account:account];
    [ApplicationManager sharedManager].isLogin = YES;
    [[ApplicationManager sharedManager].localSettingData setLastLoginAccount:account];
    [ApplicationManager sharedManager].account.userid = [NSNumber numberWithInteger:account.integerValue];
    [ApplicationManager sharedManager].account.password = md5Password;
    [[ApplicationManager sharedManager].localSettingData setAutoLoginFlag:YES];
}

#pragma mark - private
- (void)loadDefaultQuickMessageArray
{
    if (!_defaultQuickMessageArray) {
        _defaultQuickMessageArray = [[NSMutableArray alloc] init];
    }
    // check local file
    NSString *path = [YBUtility getDocumentsPath];
    path = [path stringByAppendingPathComponent:DEFAULT_QUICK_CHAT_FILE];
    if (![YBUtility fileExists:path]) {
        // copy local default to doc folder
        NSString *source = [[NSBundle mainBundle] pathForResource:@"DefaultChatMessage" ofType:@"plist"];
        [YBUtility copyFile:source to:path];
    }
    if ([YBUtility fileExists:path]) {
        [_defaultQuickMessageArray addObjectsFromArray:[NSArray arrayWithContentsOfFile:path]];
    }
}

- (void)removeQuickChat:(int)index
{
    if (index >= 0 && index < _defaultQuickMessageArray.count) {
        [_defaultQuickMessageArray removeObjectAtIndex:index];
        // save to doc path
        NSString *path = [YBUtility getDocumentsPath];
        path = [path stringByAppendingPathComponent:DEFAULT_QUICK_CHAT_FILE];
        [_defaultQuickMessageArray writeToFile:path atomically:YES];
    }
    
}

- (void)exchangeQuickChatFrom:(int)sourceIndex to:(int)destinationIndex
{
    if (sourceIndex >= 0 && sourceIndex < _defaultQuickMessageArray.count && destinationIndex >= 0 && destinationIndex < _defaultQuickMessageArray.count && sourceIndex != destinationIndex) {
        [_defaultQuickMessageArray exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        // save to doc path
        NSString *path = [YBUtility getDocumentsPath];
        path = [path stringByAppendingPathComponent:DEFAULT_QUICK_CHAT_FILE];
        [_defaultQuickMessageArray writeToFile:path atomically:YES];
    }
}

- (void)addQuickChat:(NSString*)message after:(int)index
{
    if (index >= 0 && index <= _defaultQuickMessageArray.count) {
        NSDictionary *data = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        [_defaultQuickMessageArray insertObject:data atIndex:index+1];
        NSString *path = [YBUtility getDocumentsPath];
        path = [path stringByAppendingPathComponent:DEFAULT_QUICK_CHAT_FILE];
        [_defaultQuickMessageArray writeToFile:path atomically:YES];
    }
}

@end
