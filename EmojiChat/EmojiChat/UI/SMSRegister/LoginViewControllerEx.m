//
//  LoginViewControllerEx.m
//  iChat
//
//  Created by michael on 5/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "LoginViewControllerEx.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import "CommonDefine.h"
#import "SMSRegisterViewController.h"
#import "AppConstant.h"
#import "SetPasswordViewController.h"
#import "MD5.h"

#import <Parse/Parse.h>
#import "push.h"

@interface LoginViewControllerEx ()
<
UITextFieldDelegate
>
{
    NSString *account;
    NSString *password;
}

@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *forgetButton;

- (IBAction)onLoginTouched:(id)sender;
- (IBAction)onForgetTouched:(id)sender;
- (IBAction)onBackTouched:(id)sender;
- (IBAction)onRegisterTouched:(id)sender;

@end

@implementation LoginViewControllerEx

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
    
    if ([account length] > 0) {
        // account
        self.accountTextField.text = account;
        // password
        password = [YBUtility getPasswordWithAccount:account];
        self.passwordTextField.text = password.length > MAX_LENGTH_FOR_PASSWORD ? [password substringToIndex:MAX_LENGTH_FOR_PASSWORD] : password;
    }
    
    [self updateUI];
    
    //self.accountTextField.delegate = self;
    //self.passwordTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    HttpClientHandler *handler = [[ApplicationManager sharedManager] httpClientHandler];
//    [handler registerDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Do any additional setup after loading the view.
//    HttpClientHandler *handler = [[ApplicationManager sharedManager] httpClientHandler];
//    [handler unregisterDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)updateUI {
    if (self.accountTextField.text.length <= 0 || self.passwordTextField.text.length <= 0) {
        self.loginButton.enabled = YES;
    }
    else {
        self.loginButton.enabled = YES;
    }
}

- (void)refreshWith:(NSString*)phoneNumber {
    self.passwordTextField.text = @"";
    self.accountTextField.text = phoneNumber;
    [self.passwordTextField becomeFirstResponder];
    
    [self updateUI];
}

- (void)loadForgotPasswordViewController
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SMSRegister" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
    SMSRegisterViewController *controller = [[nv childViewControllers] firstObject];
    controller.phoneNumber = self.accountTextField.text;
    __weak __typeof(self)weakSelf = self;
    controller.backBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        //[weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    controller.successBlock = ^ (NSString *phoneNumber) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            // set password
            [self loadSetPasswordViewController:NO phone:phoneNumber];
        }];
        //[weakSelf.navigationController popViewControllerAnimated:YES];
    };
    //    [self.navigationController pushViewController:nv animated:YES];
    [self presentViewController:nv animated:YES completion:NULL];
}

- (void)loadRegisterViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SMSRegister" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"SMSRegisterViewController"];
    SMSRegisterViewController *controller = [[nv childViewControllers] firstObject];
    __weak __typeof(self)weakSelf = self;
    controller.backBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        //[weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    controller.successBlock = ^ (NSString *phoneNumber) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            // update current page
//            [weakSelf refreshWith:phoneNumber];
            // set password
            [self loadSetPasswordViewController:YES phone:phoneNumber];
        }];
        //[weakSelf.navigationController popViewControllerAnimated:YES];
    };
//    [self.navigationController pushViewController:nv animated:YES];
    [self presentViewController:nv animated:YES completion:NULL];
}

- (void)loadSetPasswordViewController:(BOOL)registerMode phone:(NSString*)phone {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SMSRegister" bundle:[NSBundle mainBundle]];
    UINavigationController *nv;
    if (registerMode) {
        nv = [storyboard instantiateViewControllerWithIdentifier:@"SetPasswordViewController"];
    }
    else {
        nv = [storyboard instantiateViewControllerWithIdentifier:@"ResetPassword"];
    }
    SetPasswordViewController* controller = [[nv childViewControllers] firstObject];
    controller.registerMode = registerMode;
    controller.phoneNumber = phone;
    [self presentViewController:nv animated:YES completion:NULL];
    
    __weak __typeof(self)weakSelf = self;
    controller.successBlock = ^ {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            if (self.successBlock) {
                self.successBlock();
            }
        }];
    };
    controller.resetPasswordBlock = ^ (NSString* phoneNumber) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            self.accountTextField.text = phoneNumber;
            self.passwordTextField.text = @"";
        }];
    };
}

- (void)loginWith:(NSString*)phone password:(NSString*)password_
{
    [YBUtility showInfoHUDInView:self.view message:nil];
    
    NSString *md5Password = [password length] >= 32 ? password_ : [MD5 md5WithoutKey:password_];
    [PFUser logInWithUsernameInBackground:phone password:md5Password block:^(PFUser *user, NSError *error)
     {
         [YBUtility hideInfoHUDInView:self.view];
         
         if (user != nil)
         {
             ParsePushUserAssign();
             
             [[ApplicationManager sharedManager] saveAccount:phone password:password_];
             
             if (self.successBlock) {
                 self.successBlock();
             }
             //[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
             //[self dismissViewControllerAnimated:YES completion:nil];
         }
         else {
             //[ProgressHUD showError:error.userInfo[@"error"]];
             NSLog(@"login error : %@", error);
             [YBUtility showErrorMessageInView:self.view message:error.userInfo[@"error"] errorCode:nil];
         }
     }];
}

#pragma mark - action
- (IBAction)onLoginTouched:(id)sender {
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    account = self.accountTextField.text;
    password = self.passwordTextField.text;
    NSString *storedPassword = [YBUtility getPasswordWithAccount:account];
    if ([storedPassword hasPrefix:password]) {
        password = storedPassword;
    }
    account = [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // prevent a strange UI bug
    if ([account length] <= 0)
    {
        [YBUtility showInfoHUDInView:self.view message:@"请输入手机号"];
        [self.accountTextField becomeFirstResponder];
        return;
    }
    if ([password length] <= 0)
    {
        [YBUtility showInfoHUDInView:self.view message:@"请输入密码"];
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    
    if ([YBUtility validatePhoneNumber:account] == NO)
    {
        [YBUtility showInfoHUDInView:self.view message:@"手机号格式无效"];
        [self.accountTextField becomeFirstResponder];
        return;
    }
    
    if (password.length <= MAX_LENGTH_FOR_PASSWORD && ![YBUtility isPasswordLegal:password])
    {
        [YBUtility showInfoHUDInView:self.view message:@"密码格式无效"];
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    // show hud
    //[YBUtility showInfoHUDInView:self.view message:nil];
    // login
    //HttpClientHandler *handler = [ApplicationManager sharedManager].httpClientHandler;
    //[handler loginWithAccount:account password:password];
    [self loginWith:account password:password];
}

- (IBAction)onForgetTouched:(id)sender {
    [self loadForgotPasswordViewController];
}

- (IBAction)onBackTouched:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

- (IBAction)onRegisterTouched:(id)sender
{
    // load register viewcontroller
    [self loadRegisterViewController];
}

#pragma mark - HttpClientHandlerDelegate
- (void)didLoginSuccess:(NSNumber*)userid
{
    if (self.successBlock) {
        self.successBlock();
    }
}

- (void)didLoginFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}


@end
