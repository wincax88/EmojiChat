//
//  LocalSettingData.h
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfigureObject;
@class Assistant;

@interface LocalSettingData : NSObject

@property(assign, readwrite) BOOL           firstRun;
@property(assign, readwrite) BOOL           enableAutoLogin;
@property(nonatomic, strong) NSString*      lastLoginAccount;
@property(assign, readwrite) BOOL           enableNotifyNewMessage;
@property(nonatomic, strong) NSString*      introVersion;
@property(nonatomic, strong) NSData*        deviceTocken;
@property(nonatomic, strong) NSString*      bPushAppId;
@property(nonatomic, strong) NSString*      bPushUserId;
@property(nonatomic, strong) NSString*      bPushChannelId;
@property(nonatomic, strong) NSString*      bPushMappingId;
@property(assign, readwrite) BOOL           hasNewMessage;
@property(nonatomic, strong) NSString*      onlineVersion;
@property(nonatomic, strong) NSString*      deviceId;

- (void)setLastLoginAccount:(NSString *)account;
- (void)setAutoLoginFlag:(BOOL)enable;
- (void)enableNotifyNewMessage:(BOOL)enable;
- (void)setIntroVersion:(NSString *)value;
- (void)setDeviceTocken:(NSData*)value;
- (void)setBPushWithAppId:(NSString*)appId userId:(NSString*)userId channelId:(NSString*)channelId;
- (void)setBPushMappingId:(NSString*)value;
- (void)setOnlineVersion:(NSString*)value;
- (BOOL)hasNewVersion;
// store configure
- (void)setConfigure:(ConfigureObject*)configure;
- (ConfigureObject*)getConfigure;

- (void)saveAssitantInfo:(Assistant*)assistant;
- (NSDictionary*)getAssitantInfo:(NSString*)assistantid;

- (void)saveNotification:(NSDictionary*)userInfo key:(NSString*)key;
- (NSDictionary*)getNotificationUserInfo:(NSString*)key;
- (void)removeNotificationForKey:(NSString *)key;

//- (void)saveCookie:(NSString*)url;
//- (void)setCookie:(NSString*)url;
//- (void)deleteCookies;

@end
