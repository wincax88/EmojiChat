//
//  LocalSettingData.m
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "LocalSettingData.h"
#import "OpenUDID.h"
#import "ConfigureObject.h"
#import "Assistant.h"

#define LAST_LOGIN_ACCOUNT              @"LastLoginAccount"
#define ENABLE_AUTO_LOGIN               @"EnableAutoLogin"
#define ENABLE_NOTIFY_NEW_MESSAGE       @"EnableNotifyNewMessage"
#define ENABLE_TEXT_MODE_NO_WIFI        @"EnableTextModeNoWifi"
#define SHOW_INTRO_VERSION              @"ShowIntroVersion"
#define QUESTION_STATUS_FILTER          @"QuestionStatusFilter"
#define QUESTION_GRADE_FILTER           @"QuestionGradeFilter"
#define QUESTION_SUBJECT_FILTER         @"QuestionSubjectFilter"
#define APN_DEVICE_TOCKEN               @"TLSRemoteDeviceTocken"
#define BPUSH_APP_ID                    @"BPushAppID"
#define BPUSH_USER_ID                   @"BPushUserID"
#define BPUSH_CHANNEL_ID                @"BPushChannelID"
#define BPUSH_MAPPING_ID                @"BPushMappingID"
#define ONLINE_VERSION                  @"OnlineVersion"
#define DEVICE_ID                       @"DeviceId"
#define CONFIGURE_OBJECT                @"Configure"

@implementation LocalSettingData

- (id)init {
    self = [super init];
    if (self) {
        _firstRun = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"firstRun"])
        {
            [defaults setObject:[NSDate date] forKey:@"firstRun"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _firstRun = YES;
        }
        
        if (_firstRun) {
            _enableNotifyNewMessage = YES;
            [self enableNotifyNewMessage:YES];
            
            NSString* curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            [self setOnlineVersion:curVersion];
            
            [self initDeviceID];
        }
        else {
            _lastLoginAccount = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_LOGIN_ACCOUNT];
            _enableAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_AUTO_LOGIN];
            _enableNotifyNewMessage = [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_NOTIFY_NEW_MESSAGE];
            _introVersion = [[NSUserDefaults standardUserDefaults] stringForKey:SHOW_INTRO_VERSION];
            _deviceTocken = [[NSUserDefaults standardUserDefaults] objectForKey:APN_DEVICE_TOCKEN];
            _bPushAppId = [[NSUserDefaults standardUserDefaults] stringForKey:BPUSH_APP_ID];
            _bPushUserId = [[NSUserDefaults standardUserDefaults] stringForKey:BPUSH_USER_ID];
            _bPushChannelId = [[NSUserDefaults standardUserDefaults] stringForKey:BPUSH_CHANNEL_ID];
            _bPushMappingId = [[NSUserDefaults standardUserDefaults] stringForKey:BPUSH_MAPPING_ID];
            _onlineVersion = [[NSUserDefaults standardUserDefaults] stringForKey:ONLINE_VERSION];
            _deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICE_ID];
            if ([_deviceId length] <= 0) {
                [self initDeviceID];
            }
        }
    }
    return self;
}

- (void)initDeviceID
{
    _deviceId = [OpenUDID value];
    [[NSUserDefaults standardUserDefaults] setObject:_deviceId forKey:DEVICE_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setLastLoginAccount:(NSString *)account
{
    _lastLoginAccount = account;
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:LAST_LOGIN_ACCOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoLoginFlag:(BOOL)enable
{
    _enableAutoLogin = enable;
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:ENABLE_AUTO_LOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enableNotifyNewMessage:(BOOL)enable
{
    _enableNotifyNewMessage = enable;
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:ENABLE_NOTIFY_NEW_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIntroVersion:(NSString *)value
{
    _introVersion = value;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SHOW_INTRO_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// set device tocken
- (void)setDeviceTocken:(NSData*)value
{
    _deviceTocken = value;
    [[NSUserDefaults standardUserDefaults] setObject:_deviceTocken forKey:APN_DEVICE_TOCKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBPushWithAppId:(NSString*)appId userId:(NSString*)userId channelId:(NSString*)channelId
{
    _bPushAppId = appId;
    _bPushUserId = userId;
    _bPushChannelId = channelId;
    [[NSUserDefaults standardUserDefaults] setObject:_bPushAppId forKey:BPUSH_APP_ID];
    [[NSUserDefaults standardUserDefaults] setObject:_bPushUserId forKey:BPUSH_USER_ID];
    [[NSUserDefaults standardUserDefaults] setObject:_bPushChannelId forKey:BPUSH_CHANNEL_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBPushMappingId:(NSString*)value
{
    _bPushMappingId = value;
    [[NSUserDefaults standardUserDefaults] setObject:_bPushMappingId forKey:BPUSH_MAPPING_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOnlineVersion:(NSString*)value
{
    _onlineVersion = value;
    [[NSUserDefaults standardUserDefaults] setObject:_onlineVersion forKey:ONLINE_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasNewVersion
{
    NSString* curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([curVersion isEqualToString:_onlineVersion]) {
        return NO;
    }
    if ([curVersion compare:_onlineVersion options:NSNumericSearch] == NSOrderedDescending) {
        // actualVersion is lower than the requiredVersion
        return NO;
    }
    
    return YES;
}
/*
- (void)saveCookie:(NSString*)url {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:url];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCookie:(NSString*)url {
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:url];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

- (void)deleteCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray = [NSArray arrayWithArray:[cookieStorage cookies]];
    for (id obj in cookieArray) {
        [cookieStorage deleteCookie:obj];
    }
}
*/
// store configure
- (void)setConfigure:(ConfigureObject*)configure
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:configure];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:CONFIGURE_OBJECT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (ConfigureObject*)getConfigure
{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:CONFIGURE_OBJECT];
    if (encodedObject) {
        ConfigureObject *configure = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        return configure;
    }
    else {
        return [[ConfigureObject alloc] init];
    }
    
}

- (void)saveAssitantInfo:(Assistant*)assistant
{
    NSDictionary *data = @{@"nick" : assistant.nick,
                           @"face" : assistant.face};
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:assistant.assistantid.stringValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*)getAssitantInfo:(NSString*)assistantid
{
    NSArray *components = [assistantid componentsSeparatedByString:@"@"];
    if (components.count >= 1) {
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:components.firstObject];
        return data;
    }
    else {
        return nil;
    }
}

- (void)saveNotification:(NSDictionary*)userInfo key:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*)getNotificationUserInfo:(NSString*)key
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return data;
}

- (void)removeNotificationForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

@end
