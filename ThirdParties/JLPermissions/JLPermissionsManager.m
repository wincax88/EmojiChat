//
//  JLPermissionsManager.m
//  iParent
//
//  Created by michael on 21/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "JLPermissionsManager.h"
#import "JLCalendarPermission.h"
#import "JLContactsPermission.h"
#import "JLLocationPermission.h"
#import "JLMicrophonePermission.h"
#import "JLNotificationPermission.h"
#import "JLPhotosPermission.h"
#import "JLRemindersPermission.h"
#import "JLCameraPermission.h"

@implementation JLPermissionsManager

+ (instancetype)sharedInstance {
    static JLPermissionsManager *_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[JLPermissionsManager alloc] init];
    });
    
    return _instance;
}

- (JLAuthorizationStatus)getCalendarPermissionStatus {
    return [[JLCalendarPermission sharedInstance] authorizationStatus];
}

- (JLAuthorizationStatus)getNotificationPermissionStatus {
    return [[JLNotificationPermission sharedInstance] authorizationStatus];
}

- (JLAuthorizationStatus)getPhotosPermissionStatus {
    return [[JLPhotosPermission sharedInstance] authorizationStatus];
}

- (JLAuthorizationStatus)getLocationPermissionStatus {
    return [[JLLocationPermission sharedInstance] authorizationStatus];
}

- (JLAuthorizationStatus)getMicrophonePermissionStatus {
    return [[JLMicrophonePermission sharedInstance] authorizationStatus];
}

- (JLAuthorizationStatus)getCameraPermissionStatus {
    return [[JLCameraPermission sharedInstance] authorizationStatus];
}

- (void)authorizeCalendarPermission:(NotificationAuthorizationHandler)completion
{

    [[JLNotificationPermission sharedInstance] authorize:^(NSString *deviceID, NSError *error) {
        completion(deviceID, error);
    }];
}

- (void)authorizePhotosPermission:(AuthorizationHandler)completion
{
    [[JLPhotosPermission sharedInstance] authorize:^(bool granted, NSError *error) {
        completion(granted, error);
    }];
}

- (void)authorizeMicrophonePermission:(AuthorizationHandler)completion
{
    [[JLMicrophonePermission sharedInstance] authorize:^(bool granted, NSError *error) {
        completion(granted, error);
    }];
}

- (void)authorizeLocationPermission:(AuthorizationHandler)completion
{
    [[JLLocationPermission sharedInstance] authorize:^(bool granted, NSError *error) {
        completion(granted, error);
    }];
}

- (void)authorizeNotificationsPermission:(NotificationAuthorizationHandler)completion
{
    [[JLNotificationPermission sharedInstance] authorize:^(NSString *deviceID, NSError *error) {
        completion(deviceID, error);
    }];
}

- (void)authorizeCameraPermission:(AuthorizationHandler)completion
{
    [[JLCameraPermission sharedInstance] authorize:^(bool granted, NSError *error) {
        completion(granted, error);
    }];
    
}

@end
