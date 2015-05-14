//
//  JLCameraPermission.m
//  iParent
//
//  Created by michael on 21/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "JLCameraPermission.h"
#import "JLPermissionsCore+Internal.h"
@import AVFoundation;


#define kJLAskedForCameraPermission @"JLAskedForCameraPermission"

@implementation JLCameraPermission {
    AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
    static JLCameraPermission *_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ _instance = [[JLCameraPermission alloc] init]; });
    
    return _instance;
}

#pragma mark - Microphone

- (JLAuthorizationStatus)authorizationStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusAuthorized:
            return JLPermissionAuthorized;
        case AVAuthorizationStatusRestricted:
            return JLPermissionDenied;
        case AVAuthorizationStatusDenied:
            return JLPermissionDenied;
        case AVAuthorizationStatusNotDetermined:
            return JLPermissionNotDetermined;
        default:
            break;
    }
}

- (void)authorize:(AuthorizationHandler)completion {
    [self authorizeWithTitle:[self defaultTitle:@"相机"]
                     message:[self defaultMessage]
                 cancelTitle:[self defaultCancelTitle]
                  grantTitle:[self defaultGrantTitle]
                  completion:completion];
}

- (void)authorizeWithTitle:(NSString *)messageTitle
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
                grantTitle:(NSString *)grantTitle
                completion:(AuthorizationHandler)completion {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusAuthorized:
        {
            if (completion) {
                completion(true, nil);
            }
            break;
        }
        case AVAuthorizationStatusRestricted:
        {
            if (completion) {
                completion(false, [self previouslyDeniedError]);
            }
            break;
        }
        case AVAuthorizationStatusDenied:
        {
            if (completion) {
                completion(false, [self previouslyDeniedError]);
            }
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            _completion = completion;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles:grantTitle, nil];
            [alert show];
            break;
        }
        default:
            break;
    }
}

- (void)displayErrorDialog {
    [self displayErrorDialog:@"相机"];
}

- (void)actuallyAuthorize {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (_completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    _completion(true, nil);
                } else {
                    _completion(false, nil);
                }
            });
        }
    }];
}

- (void)canceledAuthorization:(NSError *)error {
    if (_completion) {
        _completion(false, error);
    }
}
@end