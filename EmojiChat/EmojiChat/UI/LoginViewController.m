//
//  LoginViewController.m
//  iParent
//
//  Created by michael on 13/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "LoginViewController.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import "ForgotPasswordViewController.h"
#import "RegisterViewController.h"
#import "CommonDefine.h"

@interface LoginViewController ()
<
HttpClientHandlerDelegate,
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

@implementation LoginViewController

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
    
    HttpClientHandler *handler = [[ApplicationManager sharedManager] httpClientHandler];
    [handler registerDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Do any additional setup after loading the view.
    HttpClientHandler *handler = [[ApplicationManager sharedManager] httpClientHandler];
    [handler unregisterDelegate:self];
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    ForgotPasswordViewController *controller = [[nv childViewControllers] firstObject];
    account = self.accountTextField.text;
    if ([YBUtility validatePhoneNumber:account]) {
        controller.phoneNumber = account;
    }
    __weak __typeof(self)weakSelf = self;
    // __weak ForgotPasswordViewController *weakController = controller;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^(NSString *phoneNumber){
        [weakSelf refreshWith:phoneNumber];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (void)loadRegisterViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    RegisterViewController *controller = [[nv childViewControllers] firstObject];
    account = self.accountTextField.text;
    if ([YBUtility validatePhoneNumber:account]) {
        controller.phoneNumber = account;
    }
    __weak __typeof(self)weakSelf = self;
    // __weak ForgotPasswordViewController *weakController = controller;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^(NSString *phoneNumber){
        [weakSelf refreshWith:phoneNumber];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
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
    [YBUtility showInfoHUDInView:self.view message:nil];
    // login
    HttpClientHandler *handler = [ApplicationManager sharedManager].httpClientHandler;
    [handler loginWithAccount:account password:password];
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
