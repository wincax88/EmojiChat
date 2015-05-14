//
//  JLPermissionsManager.h
//  iParent
//
//  Created by michael on 21/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLPermissionsCore.h"

@interface JLPermissionsManager : NSObject

+ (instancetype)sharedInstance;

- (JLAuthorizationStatus)getCalendarPermissionStatus;

- (JLAuthorizationStatus)getNotificationPermissionStatus;

- (JLAuthorizationStatus)getPhotosPermissionStatus;

- (JLAuthorizationStatus)getLocationPermissionStatus;

- (JLAuthorizationStatus)getMicrophonePermissionStatus;

- (JLAuthorizationStatus)getCameraPermissionStatus;

- (void)authorizeCalendarPermission:(NotificationAuthorizationHandler)completion;

- (void)authorizePhotosPermission:(AuthorizationHandler)completion;

- (void)authorizeMicrophonePermission:(AuthorizationHandler)completion;

- (void)authorizeLocationPermission:(AuthorizationHandler)completion;

- (void)authorizeNotificationsPermission:(NotificationAuthorizationHandler)completion;

- (void)authorizeCameraPermission:(AuthorizationHandler)completion;

@end
