//
//  SetPasswordViewController.m
//  iChat
//
//  Created by michael on 6/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "ApplicationManager.h"
#import "MBProgressHUD.h"
#import "YBUtility.h"
#import <Parse/Parse.h>
#import "push.h"
#import "AppConstant.h"
#import "MD5.h"

@interface SetPasswordViewController ()

- (IBAction)onBackTouched:(id)sender;
- (IBAction)onDoneTouched:(id)sender;

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)signUpWith:(NSString*)phone password:(NSString*)password nick:(NSString*)nick
{
    [YBUtility showInfoHUDInView:self.view message:nil];
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    PFUser *user = [PFUser user];
    user.username = phone;
    user.password = md5Password;
    user[PF_USER_NICKNAME] = nick;
    user[PF_USER_PHONE] = phone;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [YBUtility hideInfoHUDInView:self.view];
             ParsePushUserAssign();
             //[ProgressHUD showSuccess:@"Succeed."];
             // [self dismissViewControllerAnimated:YES completion:nil];
             // add user account and password to local storage
             [[ApplicationManager sharedManager] saveAccount:phone password:password];
             if (self.successBlock) {
                 self.successBlock();
             }
         }
         else {
             [YBUtility showErrorMessageInView:self.view message:error.userInfo[@"error"] errorCode:nil];
         }
     }];
}

- (void)resetPassword:(NSString*)phone password:(NSString*)password
{
    [YBUtility showInfoHUDInView:self.view message:nil];
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    [PFCloud callFunctionInBackground:@"resetPassword"
                       withParameters:@{@"phone":phone, @"password":md5Password}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        [YBUtility hideInfoHUDInView:self.view];
                                        if (self.resetPasswordBlock) {
                                            self.resetPasswordBlock(phone);
                                        }
                                    }
                                    else {
                                        [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                                    }
                                }];}

#pragma mark - action
- (IBAction)onBackTouched:(id)sender
{
    if (self.backBlock) {
        self.backBlock();
    }
}

- (IBAction)onDoneTouched:(id)sender
{
    if ([self.pwdTextField1.text length] <= 0) {
        [YBUtility showInfoHUDInView:self.view message:@"请输入密码"];
        [self.pwdTextField1 becomeFirstResponder];
        return;
    }
    if ([self.pwdTextField2.text length] <= 0) {
        [YBUtility showInfoHUDInView:self.view message:@"请输入密码"];
        [self.pwdTextField2 becomeFirstResponder];
        return;
    }
    if (![YBUtility isPasswordLegal:self.pwdTextField1.text]) {
        [YBUtility showInfoHUDInView:self.view message:@"密码非法，请重新输入"];
        [self.pwdTextField1 becomeFirstResponder];
        return;
    }
    if (![YBUtility isPasswordLegal:self.pwdTextField2.text]) {
        [YBUtility showInfoHUDInView:self.view message:@"密码非法，请重新输入"];
        [self.pwdTextField2 becomeFirstResponder];
        return;
    }
    if (![self.pwdTextField1.text isEqualToString:self.pwdTextField2.text]) {
        [YBUtility showInfoHUDInView:self.view message:@"两次输入的密码不匹配"];
        [self.pwdTextField1 becomeFirstResponder];
        return;
    }
    if (self.registerMode) { // register
        [self signUpWith:self.phoneNumber password:self.pwdTextField2.text nick:self.nickTextField.text];
    }
    else { // reset password
        [self resetPassword:self.phoneNumber password:self.pwdTextField2.text];
    }
}


@end
