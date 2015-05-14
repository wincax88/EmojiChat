//
//  SetPwdViewController.m
//  iStudent
//
//  Created by stephen on 11/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "SetPwdViewController.h"
#import "ApplicationManager.h"
#import "MBProgressHUD.h"
#import "YBUtility.h"

@interface SetPwdViewController ()
<
HttpClientHandlerDelegate
>

@property (nonatomic, retain) UIAlertView* alertView;

@end

@implementation SetPwdViewController

- (void)dealloc {
    self.pwdTextField1 = nil;
    self.pwdTextField2 = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)back:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

- (IBAction)setPwd:(id)sender {
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
    
    [YBUtility showInfoHUDInView:self.view message:nil];
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    if (self.registerMode) {
        [[ApplicationManager sharedManager].httpClientHandler registerWithPhoneNumber:self.phoneNumber verifyCode:self.verifyCode password:self.pwdTextField1.text];
    }
    else {
        [[ApplicationManager sharedManager].httpClientHandler resetPwd:self.phoneNumber pwd:self.pwdTextField1.text verifyCode:self.verifyCode];
    }
}

#pragma mark - HttpClientHandlerDelegate
- (void)didResetPwdSuccess:(NSDictionary*)userData {
    [YBUtility hideInfoHUDInView:self.view];
    // update local data
    NSString *phone = [userData objectForKey:@"phone"];
    NSString *passwd = [userData objectForKey:@"passwd"];
    [YBUtility savePassword:passwd account:phone];
    if (self.successBlock) {
        self.successBlock();
    }
}

- (void)didResetPwdFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didRegisterSuccess:(NSNumber*)successCode account:(NSNumber*)userid
{
    [YBUtility hideInfoHUDInView:self.view];
    // update local data
    if (self.successBlock) {
        self.successBlock();
    }
}

- (void)didRegisterFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

@end
