//
//  JLPermissionCore.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissionsCore.h"

@implementation JLPermissionsCore

- (NSString *)defaultTitle:(NSString *)authorizationType {
  return [NSString
      stringWithFormat:@"\"%@\" 想要访问您的 %@", [self appName], authorizationType];
}

- (NSString *)defaultMessage {
  return nil;
}

- (NSString *)defaultCancelTitle {
  return @"不允许";
}

- (NSString *)defaultGrantTitle {
  return @"好";
}

- (NSString *)appName {
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (void)displayErrorDialog:(NSString *)authorizationType {
  NSString *message = [NSString stringWithFormat:@"请到设置 -> 隐私 -> "
                                                 @"%@ to 重设 %@'s 权限.",
                                                 authorizationType, [self appName]];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"好"
                                        otherButtonTitles:nil];
  [alert show];
}

- (NSError *)previouslyDeniedError {
  return [NSError errorWithDomain:@"PreviouslyDenied" code:JLPermissionDenied userInfo:nil];
}

- (NSError *)systemDeniedError:(NSError *)error {
  return
      [NSError errorWithDomain:@"SystemDenied" code:JLPermissionDenied userInfo:[error userInfo]];
}

- (void)actuallyAuthorize {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

- (void)canceledAuthorization:(NSError *)error {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  BOOL canceled = (buttonIndex == alertView.cancelButtonIndex);
  dispatch_async(dispatch_get_main_queue(), ^{
      if (canceled) {
        NSError *error =
            [NSError errorWithDomain:@"UserDenied" code:JLPermissionDenied userInfo:nil];
        [self canceledAuthorization:error];
      } else {
        [self actuallyAuthorize];
      }
  });
}

@end
