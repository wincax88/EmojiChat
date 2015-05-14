//
//  VerifyCodeViewController.m
//  iStudent
//
//  Created by stephen on 11/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import "MBProgressHUD.h"
#import "TimerManager.h"
#import "CommonDefine.h"
#import "SetPwdViewController.h"

@interface VerifyCodeViewController ()
<
TimerManagerDelegate,
HttpClientHandlerDelegate
>
{
    NSTimeInterval beginTime;
}

@property (nonatomic, retain) IBOutlet UITextField* verifyCodeTextField;
@property (nonatomic, retain) IBOutlet UILabel* countdownLabel;
@property (nonatomic, retain) IBOutlet UILabel* commentLabel;
@property (nonatomic, assign) NSInteger limitTime;

- (IBAction)getVerifyCode:(id)sender;
- (IBAction)checkVierifyCode:(id)sender;
- (IBAction)back:(id)sender;

@end

@implementation VerifyCodeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _limitTime = 60;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    beginTime = CFAbsoluteTimeGetCurrent();
    
    self.countdownLabel.textColor = DEFAULT_COLOR_GRAY;
    self.countdownLabel.text = [NSString stringWithFormat:@"%d秒", self.limitTime];
    
    self.verifyCodeTextField.placeholder = [NSString stringWithFormat:@"编号为%@的验证码", self.messageNumber];

    self.commentLabel.text = [NSString stringWithFormat:@"短信验证码已发送到：%@", self.phoneNumber];
}

- (void)dealloc {
    self.verifyCodeTextField = nil;
    self.phoneNumber = nil;
    self.verifyCode = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    [[ApplicationManager sharedManager].timerManager registerDelegate:self];
    
    [self.verifyCodeTextField becomeFirstResponder];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [[ApplicationManager sharedManager].timerManager unregisterDelegate:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)getVerifyCode:(id)sender {
    if ([self.countdownLabel.text isEqualToString:@"重新获取"]) {
        self.verifyCodeTextField.text = nil;
        [YBUtility showInfoHUDInView:self.view message:nil];
        [[ApplicationManager sharedManager].httpClientHandler verifyPhoneNumber:self.phoneNumber];
    }
}

- (IBAction)checkVierifyCode:(id)sender {
    self.verifyCode = self.verifyCodeTextField.text;
    self.verifyCode = [self.verifyCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.verifyCode length] <= 0) {
        [YBUtility showInfoHUDInView:self.view message:@"请输入验证码"];
        [self.verifyCodeTextField becomeFirstResponder];
        return;
    }
    [YBUtility showInfoHUDInView:self.view message:nil];
    [[ApplicationManager sharedManager].httpClientHandler checkVerifyCode:self.phoneNumber verifyCode:self.verifyCodeTextField.text];
}

- (IBAction)back:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

#pragma mark - TimerManagerDelegate
- (void)onTimerFire:(NSNumber*)timeInterval {
    
    NSTimeInterval past = CFAbsoluteTimeGetCurrent() - beginTime;
    int leftTime = self.limitTime - (int)past;
    
    if (leftTime <= 0) {
        self.countdownLabel.text = @"重新获取";
        self.countdownLabel.textColor = DEFAULT_COLOR_BLUE;
        [[ApplicationManager sharedManager].timerManager unregisterDelegate:self];
    }
    else {
        self.countdownLabel.textColor = DEFAULT_COLOR_GRAY;
        self.countdownLabel.text = [NSString stringWithFormat:@"%d秒", leftTime];
    }
}

- (void)loadSetPwdViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"SetPwdViewController"];
    SetPwdViewController* controller = [[nv childViewControllers] firstObject];
    controller.phoneNumber = self.phoneNumber;
    controller.verifyCode = self.verifyCode;
    
    [self.navigationController pushViewController:controller animated:YES];

    
}
#pragma mark - HttpClientHandlerDelegate

- (void)didCheckVerifyCodeSuccess {
    [YBUtility hideInfoHUDInView:self.view];
    
    if (self.successBlock) {
        self.successBlock(self.verifyCode);
    }
}

- (void)didCheckVerifyCodeFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didVerifyPhoneNumberSuccess:(NSDictionary*)userData {
    [YBUtility hideInfoHUDInView:self.view];
    self.verifyCode = [userData objectForKey:@"code"];
    beginTime = CFAbsoluteTimeGetCurrent();
    self.messageNumber = [userData objectForKey:@"msg_num"];
    self.verifyCodeTextField.placeholder = [NSString stringWithFormat:@"编号为（%@）的验证码", self.messageNumber];
    [[ApplicationManager sharedManager].timerManager registerDelegate:self];
}

- (void)didVerifyPhoneNumberFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    self.verifyCode = nil;
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

@end
