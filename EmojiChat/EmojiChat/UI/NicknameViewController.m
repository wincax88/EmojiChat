//
//  NicknameViewController.m
//  taozuoye
//
//  Created by michaelwong on 4/4/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "NicknameViewController.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

#define TAG_NICKNAME_HUD 201404071

@interface NicknameViewController () <HttpClientHandlerDelegate>


@property (retain, nonatomic) IBOutlet UITextField *nicknameTextField;

- (IBAction)onBackButtonTouched:(id)sender;
- (IBAction)onSaveButtonTouched:(id)sender;

@end

@implementation NicknameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.nickname = [ApplicationManager sharedManager].account.nick;
    self.nicknameTextField.text = self.nickname;
    [self.nicknameTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.nicknameTextField resignFirstResponder];
	// Do any additional setup after loading the view.
    HttpClientHandler *handler = [[ApplicationManager sharedManager] httpClientHandler];
    [handler unregisterDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)onBackButtonTouched:(id)sender
{
    if (self.backBlock) {
        self.backBlock();
    }
}

- (IBAction)onSaveButtonTouched:(id)sender
{
    [self.nicknameTextField resignFirstResponder];
    
    self.nickname = self.nicknameTextField.text;
    self.nickname = [self.nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // if no changed , go back
    if ([self.nickname isEqual:[ApplicationManager sharedManager].account.nick]) {
        [self onBackButtonTouched:nil];
        return;
    }
    // nick length
    if ([YBUtility checkNicknameLength:self.nickname] == NO) {
        [YBUtility showInfoHUDInView:self.view message:@"昵称支持6-16个字母、数字、下划线或中文"];
        return;
    }
    
    // verify nickname
    if (![YBUtility isNicknameLegal:self.nickname]) {
        [YBUtility showInfoHUDInView:self.view message:@"昵称格式不符"];
        return;      
    }
    // show progress view
    [YBUtility showInfoHUDInView:self.view message:nil];
    // post nickname chage request to server
    //HttpClientHandler *handler = [ApplicationManager sharedManager].httpClientHandler;
    //[handler registerDelegate:self];
    //[handler setNick:self.nickname];
    NSString *account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
    NSString *password = [YBUtility getPasswordWithAccount:account];
    PFUser *user = [PFUser logInWithUsername:account password:password];
    user[PF_USER_NICKNAME] = self.nickname;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
         else {
             // update UI
             [self didSetNickSuccess:@{@"nick":self.nickname}];
         }
     }];
}

#pragma mark - HttpClientHandlerDelegate
- (void)didSetNickSuccess:(NSDictionary*)userData
{
    [YBUtility hideInfoHUDInView:self.view];
    [ApplicationManager sharedManager].account.nick = [userData objectForKey:@"nick"];
    
    if (self.saveBlock) {
        self.saveBlock([ApplicationManager sharedManager].account.nick);
    }
}

- (void)didSetNickFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}


@end
