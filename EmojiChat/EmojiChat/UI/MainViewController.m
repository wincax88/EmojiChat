//
//  MainViewController.m
//  handChat
//
//  Created by michael on 8/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "MainViewController.h"
#import "MineViewController.h"
#import "CommonDefine.h"
#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "UIAlertView+Blocks.h"
#import "MD5.h"
#import "iVersion.h"
#import "UITabBarItem+CustomBadge.h"
#import "BaseViewController.h"
#import "AddressBookSingleton.h"
#import "AddressBook.h"
#import "QuickAnswerViewController.h"
#import "YoViewController.h"
#import "LoginViewControllerEx.h"
#import <Parse/Parse.h>
#import "push.h"
#import "AppConstant.h"

#define USING_SMS_REGISTER 1

@interface MainViewController ()
{
    YoViewController *yoViewController;
}

- (IBAction)onInfoTouched:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestAccessAddressBook];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewQuickMessage:) name:PNS_QUICK_MESSAGE object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"YoViewController"]) {
        yoViewController = [segue destinationViewController];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - public

- (void)refresh {
    if (yoViewController) {
        [yoViewController refresh];
    }
}

- (BOOL)autoLogin
{
    NSString *account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
    NSString *password = [YBUtility getPasswordWithAccount:account];
    if ([account length] > 0 && [password length] > 0) {
        [PFUser logInWithUsernameInBackground:account password:password block:^(PFUser *user, NSError *error)
         {
             if (user != nil)
             {
                 [[ApplicationManager sharedManager] saveAccount:account password:password];
                 
                 ParsePushUserAssign();
                 
                 [self doLoginPostProcess];
             }
             else {
                 //[ProgressHUD showError:error.userInfo[@"error"]];
                 NSLog(@"login error : %@", error);
                 [YBUtility showErrorMessageInView:self.view message:error.userInfo[@"error"] errorCode:nil];
                 [self loadLoginViewController];
             }
         }];
        return YES;
    }
    return NO;
}

- (void)loadLoginViewController {
#if (USING_SMS_REGISTER)
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewControllerEx"];
    LoginViewControllerEx *controller = [[nv childViewControllers] firstObject];
    __weak __typeof(self)weakSelf = self;
    controller.backBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    controller.successBlock = ^  {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            // update current page
            //            [weakSelf refreshCurPage];
        }];
    };
    
    [self presentViewController:nv animated:YES completion:NULL];
#else
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    LoginViewController *controller = [[nv childViewControllers] firstObject];
    __weak __typeof(self)weakSelf = self;
    controller.backBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    controller.successBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            // update current page
            //            [weakSelf refreshCurPage];
        }];
    };
    
    [self presentViewController:nv animated:YES completion:NULL];
#endif
}

- (void)showQuickAnswerView
{
    if ([self.presentedViewController isKindOfClass:[QuickAnswerViewController class]]) {
        [(QuickAnswerViewController*)self.presentedViewController refresh];
        return;
    }
    // QuickAnswerViewController
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"QuickAnswer" bundle:[NSBundle mainBundle]];
    QuickAnswerViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"QuickAnswerViewController"];
    [self presentViewController:controller animated:YES completion:^{
        ;
    }];
    controller.closeBlock = ^ {
        [self dismissViewControllerAnimated:YES completion:^{
            [[ApplicationManager sharedManager].quickAnswerList removeAllObjects];
        }];
    };
}

#pragma mark - private

- (void)doLoginPostProcess
{
    //
    [self getFriendList];
    //
    [self getInviteUser];
    //
    [self getConfirmList];
    
}

- (void)requestAccessAddressBook
{
    [AddressBook sharedInstance].addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (&ABAddressBookRequestAccessWithCompletion != NULL) {
        
        ABAddressBookRequestAccessWithCompletion([AddressBook sharedInstance].addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                [YBUtility showInfoHUDInView:self.view message:@"没有获得访问通讯录的权限，请在系统设置中变更。"];
                CFRelease(error);
            }
            else {
            }
        });
    }
}
- (void)getConfigure
{
    if ([ApplicationManager sharedManager].configureObject.update.boolValue) {
        return;
    }
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    [[ApplicationManager sharedManager].httpClientHandler getConfigure];
}

- (void)getInviteUser
{
    PFUser *curUser = [PFUser currentUser];
    // remove phone from invite table
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inviterPhone = %@", curUser[PF_USER_PHONE]];
    PFQuery *query = [PFQuery queryWithClassName:PF_INVITE_CLASS_NAME predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //
            [[ApplicationManager sharedManager].inviteUserArray removeAllObjects];
            for (PFObject *invite in objects) {
                [[ApplicationManager sharedManager].inviteUserArray addObject:invite[PF_INVITE_INVITEE_PHONE]];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)getFriendList
{
    PFUser *curUser = [PFUser currentUser];
    // get friends in friend table
    PFQuery *query = [PFQuery queryWithClassName:PF_FRIEND_CLASS_NAME];
    [query whereKey:PF_FRIEND_MSATER_OBJECT equalTo:curUser];
    [query includeKey:PF_FRIEND_BUDDY_OBJECT];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error) {
            //
            [[ApplicationManager sharedManager].friendList removeAllObjects];
            for (PFObject *relation in objects) {
                PFUser *friendUser = relation[PF_FRIEND_BUDDY_OBJECT];
                /*
                ChatBuddy *buddy = [[ChatBuddy alloc] init];
                buddy.userId = friendUser[PF_USER_PHONE];
                buddy.nickName = friendUser[PF_USER_NICKNAME];;
                // buddy.avatarUrl = [item objectForKey:@"face"];
                buddy.phoneNumber = friendUser[PF_USER_PHONE];*/
                [[ApplicationManager sharedManager].friendList addObject:friendUser];
            }
            
            // refresh ui
            [self refresh];
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
    /*
    PFUser *curUser = [PFUser currentUser];
    // remove phone from invite table
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"master = %@", curUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_FRIEND_CLASS_NAME predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //
            [[ApplicationManager sharedManager].chatBuddyList removeAllObjects];
            for (PFUser *member in objects) {
                ChatBuddy *buddy = [[ChatBuddy alloc] init];
                buddy.userId = member[PF_USER_PHONE];
                buddy.nickName = member[PF_USER_NICKNAME];
                buddy.avatarUrl = member[PF_USER_THUMBNAIL];
                [[ApplicationManager sharedManager].inviteUserArray addObject:buddy];
            }
            // refresh ui
            [self refresh];
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];*/
}

- (void)getConfirmList
{
    PFUser *curUser = [PFUser currentUser];
    // remove phone from invite table
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inviteePhone = %@", curUser[PF_USER_PHONE]];
    PFQuery *query = [PFQuery queryWithClassName:PF_INVITE_CLASS_NAME predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //
            [[ApplicationManager sharedManager].confirmList removeAllObjects];
            for (PFObject *invite in objects) {
                AccountObject *confirm = [[AccountObject alloc] init];
                NSString *inviterPhone = invite[PF_INVITE_INVITER_PHONE];
                confirm.userid = [NSNumber numberWithLongLong:inviterPhone.longLongValue];
                confirm.nick = invite[PF_INVITE_INVITER_NICK];
                confirm.face = invite[PF_INVITE_INVITER_AVATAR];
                confirm.relationShip = kContactIsInvitee;
                [[ApplicationManager sharedManager].confirmList addObject:confirm];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)loadMineViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"MineViewController"];
    MineViewController *controller = [[nv childViewControllers] firstObject];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:controller animated:YES];

                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
     
    //[self.navigationController pushViewController:controller animated:YES];
    controller.backBlock = ^ {
        
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [self.navigationController popViewControllerAnimated:YES];
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                         }];
         
        //[self.navigationController popViewControllerAnimated:YES];
    };
    
}
#pragma mark - HttpClientHandlerDelegate
- (void)didLoginSuccess:(NSNumber*)userid {
    [YBUtility hideInfoHUDInView:self.view];
    
    
//    if ([[ApplicationManager sharedManager].configureObject.chat_xmpp length] > 0) {
//        // login to chat server and fetch message
//        [self loginChatServer:[ApplicationManager sharedManager].configureObject.chat_xmpp port:[ApplicationManager sharedManager].configureObject.chat_xmpp_port];
//    }
    //
    [self getConfigure];
    //
    [self getFriendList];
    //
    [self getInviteUser];
    //
    [self getConfirmList];
    
    // upload token
    NSString *bPushUserId = [ApplicationManager sharedManager].localSettingData.bPushUserId;
    NSString *bPushChannelId = [ApplicationManager sharedManager].localSettingData.bPushChannelId;
    [[ApplicationManager sharedManager].httpClientHandler uploadPushToken:bPushUserId channelid:bPushChannelId];
    
    // if nick name is empty, add badge
//    if ([ApplicationManager sharedManager].account.nick.length <= 0) {
//        [self setBadgeValue:@"" forIndex:kTabIndexMine];
//    }
    
}

- (void)didLoginFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    [UIAlertView showWithTitle:nil message:@"登录失败，请重新尝试。" cancelButtonTitle:@"再试一次" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self loadLoginViewController];
    }];
    
}

- (void)didUnLoginError:(NSDictionary*)data
{
    BOOL canAutoLogin = NO;
    static int autoLoginCount = 0;
    // check login state
    if ([ApplicationManager sharedManager].account.userid.intValue <= 0) {
        if ([ApplicationManager sharedManager].localSettingData.enableAutoLogin && autoLoginCount <= 5) {
            // do auto login
            if ([self autoLogin]) {
                autoLoginCount++;
                canAutoLogin = YES;
            }
        }
    }
    if (!canAutoLogin) {
        [UIAlertView showWithTitle:nil message:@"请重新登录" cancelButtonTitle:@"登录" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // show login view
            [self loadLoginViewController];
        }];
    }
}

- (void)didGetChildrenFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didHTTPRequestError:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    NSString *messgae = [NSString stringWithFormat:@"网络错误（%@）", errorCode];
    [YBUtility showErrorMessageInView:self.view message:messgae errorCode:errorCode];
}

/** ------------ get configure ------------ **/
- (void)didGetConfigureSuccess
{
    // if chat server not login
    if ([[ApplicationManager sharedManager].configureObject.chat_xmpp length] > 0 &&
        [ApplicationManager sharedManager].account.userid.intValue > 0) {
        // login to chat server and fetch message
//        [self loginChatServer:[ApplicationManager sharedManager].configureObject.chat_xmpp port:[ApplicationManager sharedManager].configureObject.chat_xmpp_port];
    }
    
}

- (void)didGetConfigureFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
#ifdef DEBUG
    
    NSLog(@"didGetConfigureFailed : %@", errorMessage);
#endif
    
}

- (void)didUploadPushTokenSuccess
{
#ifdef DEBUG
    
    NSLog(@"didUploadPushTokenSuccess");
#endif
}

- (void)didUploadPushTokenFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
#ifdef DEBUG
    
    NSLog(@"didUploadPushTokenFailed : %@", errorMessage);
#endif
}

- (void)didGetInviteUserSuccess
{
    
}

- (void)didGetInviteUserFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didGetFriendsSuccess
{
    /*
     ChatBuddy *person = [[ChatBuddy alloc] init];
     person.userId = [[NSNumber numberWithInt:60000] stringValue];
     person.avatarUrl = @"http://7xipis.com2.z0.glb.qiniucdn.com/C098C655-2DFD-4506-BDB3-E236204BFE16_60030.png";
     person.nickName = @"文职";
     person.phoneNumber = @"13564417734";
     
     [[ApplicationManager sharedManager].chatBuddyList addObject:person];
     */
    // refresh ui
    [self refresh];
}

- (void)didGetFriendsFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didGetConfirmListSuccess:(NSDictionary*)userData
{
//    if ([ApplicationManager sharedManager].confirmList.count > 0) {
//        [self setBadgeValue:@"" forIndex:kTabIndexMine];
//    }
}

- (void)didGetConfirmListFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

#pragma mark - action
- (IBAction)onInfoTouched:(id)sender {
    // show setting page
    [self loadMineViewController];
}

- (void)onNewQuickMessage:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *applicationState = [userInfo objectForKey:@"applicationState"];
    if (applicationState.intValue == UIApplicationStateActive) {
        
        // popup quick answer view
        [self showQuickAnswerView];
    }
    else {
        
        [self performSelector:@selector(showQuickAnswerView) withObject:nil afterDelay:3.0f];
    }
}

@end
