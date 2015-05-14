//
//  RegisterViewController.m
//  iChat
//
//  Created by michael on 21/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "RegisterViewController.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import "SetPwdViewController.h"
#import "MBProgressHUD.h"
#import "VerifyCodeViewController.h"
#import "UIAlertView+Blocks.h"

@interface RegisterViewController ()
<
HttpClientHandlerDelegate
>

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)onNextTouched:(id)sender;
- (IBAction)onBackTouched:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneTextField.text = self.phoneNumber;
    
    //    self.nextButton.enabled = [self.phoneTextField.text length] > 0 ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    
    [super viewWillAppear:animated];
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
- (IBAction)onNextTouched:(id)sender {
    [self.phoneTextField resignFirstResponder];
    
    self.phoneNumber = self.phoneTextField.text;
    
    // prevent a strange UI bug
    if ([self.phoneNumber length] <= 0)
    {
        [YBUtility showInfoHUDInView:self.view message:@"请输入手机号"];
        [self.phoneTextField becomeFirstResponder];
        return;
    }
    
    if ([YBUtility validatePhoneNumber:self.phoneNumber ] == NO)
    {
        [YBUtility showInfoHUDInView:self.view message:@"手机号格式无效"];
        [self.phoneTextField becomeFirstResponder];
        return;
    }
    // show hud
    [YBUtility showInfoHUDInView:self.view message:nil];
    // login
    HttpClientHandler *handler = [ApplicationManager sharedManager].httpClientHandler;
    [handler verifyPhoneNumber:self.phoneNumber];
}

- (IBAction)onBackTouched:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

#pragma mark - private

- (void)loadVerifyCodeViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"VerifyCodeViewController"];
    VerifyCodeViewController* controller = [[nv childViewControllers] firstObject];
    controller.phoneNumber = self.phoneNumber;
    controller.verifyCode = self.verifyCode;
    controller.messageNumber = self.messageNumber;
    [self.navigationController pushViewController:controller animated:YES];
    __weak __typeof(self) weakSelf = self;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^(NSString *verifyCode){
        weakSelf.verifyCode = verifyCode;
        [weakSelf.navigationController popViewControllerAnimated:NO];
        [weakSelf loadSetPwdViewController];
    };
}

- (void)loadSetPwdViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"SetPwdViewController"];
    SetPwdViewController* controller = [[nv childViewControllers] firstObject];
    controller.phoneNumber = self.phoneNumber;
    controller.verifyCode = self.verifyCode;
    controller.registerMode = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:NO];
        if (self.successBlock) {
            self.successBlock(weakSelf.phoneNumber);
        }
    };
}

#pragma mark - private

- (void)didVerifyPhoneNumberSuccess:(NSDictionary*)userData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([[userData objectForKey:@"phone"] isEqual:self.phoneNumber]) {
        self.verifyCode = [userData objectForKey:@"code"];
        self.messageNumber = [userData objectForKey:@"msg_num"];
    }
    
    [self loadVerifyCodeViewController];
    
}

- (void)didVerifyPhoneNumberFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

@end
