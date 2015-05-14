//
//  LoginHandler.m
//  iChat
//
//  Created by michael on 6/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "LoginHandler.h"
#import <Parse/Parse.h>
#import "YBUtility.h"
#import "AppConstant.h"
#import "MD5.h"


@implementation LoginHandler

- (BOOL)hasAccount
{
    return ([PFUser currentUser] != nil);
}

- (void)setAvatar:(NSString*)imageFile
{
    UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImage *picture = [YBUtility scaleImage:image toSize:CGSizeMake(280, 280)];
    UIImage *thumbnail = [YBUtility scaleImage:image toSize:CGSizeMake(60, 60)];
    
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.7)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [YBUtility showInfoHUDInView:nil message:@"Network error"];
         }
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.7)];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [YBUtility showInfoHUDInView:nil message:@"Network error"];
         }
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *user = [PFUser currentUser];
    user[PF_USER_PICTURE] = filePicture;
    user[PF_USER_THUMBNAIL] = fileThumbnail;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [YBUtility showInfoHUDInView:nil message:@"Network error"];
         }
     }];
    
}

- (void)signUpWith:(NSString*)phone password:(NSString*)password
{
    PFUser *user = [PFUser user];
    user.username = phone;
    user.password = password;
    user[PF_USER_FULLNAME] = phone;
    user[PF_USER_FULLNAME_LOWER] = [phone lowercaseString];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             // ParsePushUserAssign();
             //[ProgressHUD showSuccess:@"Succeed."];
             // [self dismissViewControllerAnimated:YES completion:nil];
         }
         else {
             // [ProgressHUD showError:error.userInfo[@"error"]];
         }
     }];
}

- (void)loginWith:(NSString*)phone password:(NSString*)password
{
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    [PFUser logInWithUsernameInBackground:phone password:md5Password block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             //ParsePushUserAssign();
             //[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
             //[self dismissViewControllerAnimated:YES completion:nil];
         }
         else {
             //[ProgressHUD showError:error.userInfo[@"error"]];
         }
     }];
}

- (void)logOut
{
    [PFUser logOut];
}

@end
