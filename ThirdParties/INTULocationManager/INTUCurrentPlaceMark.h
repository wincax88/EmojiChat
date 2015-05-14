//
//  INTUCurrentPlaceMark.h
//
//  Created by michaelwong on 9/17/14.
//  Copyright (c) 2014 Intuit Inc. All rights reserved.
//
/*
 1. placeMark = [[INTUCurrentPlaceMark alloc] init];
    placeMark.delegate = self;
 2. [placeMark startLocationRequest];

 */

#import "INTULocationManager.h"

@class INTUCurrentPlaceMark;

@protocol INTUCurrentPlaceMarkDelegate <NSObject>

@required

- (void)didLocationRequestSuccess:(CLPlacemark*)placemark;
- (void)didLocationRequestTimeOut;
- (void)didLocationRequestFailed:(NSInteger)errorCode errorString:(NSString*)errorString;

@end

@interface INTUCurrentPlaceMark : NSObject

@property (assign, nonatomic) CLPlacemark           *placemark;
@property (assign, nonatomic) INTULocationAccuracy  desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval        timeout;
@property (assign, nonatomic) NSString              *errorString;
@property (assign, nonatomic) NSInteger             errorCode;
@property (assign, nonatomic) id<INTUCurrentPlaceMarkDelegate> delegate;

- (void)startLocationRequest;
- (void)cancelRequest;
- (void)forceCompleteRequest;

@end
