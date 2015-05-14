//
//  INTUCurrentPlaceMark.m
//  LocationManagerExample
//
//  Created by michaelwong on 9/17/14.
//  Copyright (c) 2014 Intuit Inc. All rights reserved.
//

#import "INTUCurrentPlaceMark.h"

@interface INTUCurrentPlaceMark ()

@property (assign, nonatomic) NSInteger locationRequestID;

@end

@implementation INTUCurrentPlaceMark

- (id)init {
    self = [super init];
    if (self) {
        _desiredAccuracy = INTULocationAccuracyCity;
        _timeout = 10;
        _locationRequestID = NSNotFound;
    }
    return self;
}

- (void)startLocationRequest
{
    __weak __typeof(self) weakSelf = self;
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:self.desiredAccuracy
                                                                timeout:self.timeout
                                                   delayUntilAuthorized:YES
                                                                  block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status)
    {
        __typeof(weakSelf) strongSelf = weakSelf;
        
        weakSelf.errorCode = status;
        if (status == INTULocationStatusSuccess)
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (!error && [placemarks count] > 0)
                 {
                     strongSelf.placemark = [placemarks firstObject];
                     // achievedAccuracy is at least the desired accuracy (potentially better)
                     // NSLog(@"Location request successful! Current Location:%@", strongSelf.placemark.administrativeArea);
                     
                     if (strongSelf.delegate) {
                         [strongSelf.delegate didLocationRequestSuccess:strongSelf.placemark];
                     }
                 }
             }];
            
            //[locMgr.placemark.locality];
        }
        else if (status == INTULocationStatusTimedOut) {
            // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
            strongSelf.errorString = @"Location request timed out.";
            if (strongSelf.delegate) {
                [strongSelf.delegate didLocationRequestTimeOut];
            }
            
        }
        else {
            // An error occurred
            if (status == INTULocationStatusServicesNotDetermined) {
                strongSelf.errorString = @"User has not responded to the permissions alert.";
            } else if (status == INTULocationStatusServicesDenied) {
                strongSelf.errorString = @"User has denied this app permissions to access device location.";
            } else if (status == INTULocationStatusServicesRestricted) {
                strongSelf.errorString = @"User is restricted from using location services by a usage policy.";
            } else if (status == INTULocationStatusServicesDisabled) {
                strongSelf.errorString = @"Location services are turned off for all apps on this device.";
            } else {
                strongSelf.errorString = @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
            }
            if (strongSelf.delegate) {
                [strongSelf.delegate didLocationRequestFailed:strongSelf.errorCode errorString:strongSelf.errorString];
            }
        }
        
        strongSelf.locationRequestID = NSNotFound;
    }];
}

- (void)cancelRequest
{
    if (NSNotFound != self.locationRequestID ) {
        [[INTULocationManager sharedInstance] cancelLocationRequest:self.locationRequestID];
        self.locationRequestID = NSNotFound;
    }
}

- (void)forceCompleteRequest
{
    if (NSNotFound != self.locationRequestID ) {
        [[INTULocationManager sharedInstance] forceCompleteLocationRequest:self.locationRequestID];
        self.locationRequestID = NSNotFound;
    }
}


@end
