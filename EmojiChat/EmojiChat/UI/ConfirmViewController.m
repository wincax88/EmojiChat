//
//  ConfirmViewController.m
//  iChat
//
//  Created by michael on 24/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ConfirmViewController.h"
#import "ApplicationManager.h"
#import "ContactCell.h"
#import "YBUtility.h"
#import "UIAlertView+Blocks.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface ConfirmViewController ()
{
    NSArray *confirmArray;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    confirmArray = [ApplicationManager sharedManager].confirmList;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    //[[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    //    [iVersion sharedInstance].delegate = nil;
    //    [iRate sharedInstance].delegate = nil;
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)removeInvite:(NSString*)userId selector:(SEL)selector
{
    PFUser *curUser = [PFUser currentUser];
    // remove phone from invite table
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(inviterPhone = %@ AND inviteePhone = %@) || (inviterPhone = %@ AND inviteePhone = %@)", userId, curUser[PF_USER_PHONE], curUser[PF_USER_PHONE], userId];
    PFQuery *query = [PFQuery queryWithClassName:PF_INVITE_CLASS_NAME predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *object = objects.firstObject;
            if (object) {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error) {
                    if ([self respondsToSelector:selector]) {
                        [self performSelector:selector withObject:userId];
                    }
                }];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)sendAccept2User:(NSString*)userId
{
//    [YBUtility showInfoHUDInView:self.view message:nil];
//    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
//    [[ApplicationManager sharedManager].httpClientHandler acceptInviteWithUser:userId];
    // add phone to friend table
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_PHONE equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *buddy = objects.firstObject;
            if (buddy) {
                PFUser *curUser = [PFUser currentUser];
                PFObject *friend = [PFObject objectWithClassName:PF_FRIEND_CLASS_NAME];
                friend[PF_FRIEND_MSATER_OBJECT] = curUser;
                friend[PF_FRIEND_BUDDY_OBJECT] = buddy;
                [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        // remove phone from invite table
                        [self removeInvite:userId selector:@selector(didAcceptInviteSuccess:)];
                    }
                    else {
                        [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                    }
                }];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
    
}

- (void)sendRefuset2User:(NSString*)userId
{
//    [YBUtility showInfoHUDInView:self.view message:nil];
//    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
//    [[ApplicationManager sharedManager].httpClientHandler refuseInviteWithUser:userId];
    [self removeInvite:userId selector:@selector(didRefuseInviteSuccess:)];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [confirmArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    AccountObject *person = [confirmArray objectAtIndex:indexPath.row];
    
    [cell setContact:person];
    
    cell.acceptBlock = ^(NSString *userId) {
        if (userId.length > 0) {
            // send invite to this phone
            [self sendAccept2User:userId];
        }
    };
    
    cell.refuseBlock = ^(NSString *userId) {
        if (userId.length > 0) {
            NSString *message = [NSString stringWithFormat:@"确定要拒绝（%@）的请求吗？", person.nick];
            [UIAlertView showWithTitle:nil message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    // send invite to this phone
                    [self sendRefuset2User:userId];
                }
            }];
        }
    };
    
    return cell;
    
}

#pragma mark - http

- (void)didAcceptInviteSuccess:(NSString*)userId
{
    [YBUtility hideInfoHUDInView:self.view];
    
    BOOL found = NO;
    // change contact status
    NSArray *fliter = [confirmArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userid == %@", [NSNumber numberWithLongLong:userId.longLongValue]]];
    if (fliter.count > 0) {
        found = YES;
        AccountObject *person = fliter.firstObject;
        person.relationShip = kContactIsFriend;
    }
    if (found) {
        [self.tableView reloadData];
    }
}

- (void)didAcceptInviteFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didRefuseInviteSuccess:(NSString*)userId
{
    [YBUtility hideInfoHUDInView:self.view];
    BOOL found = NO;
    // change contact status
    NSArray *fliter = [confirmArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userid == %@", [NSNumber numberWithInteger:userId.integerValue]]];
    if (fliter.count > 0) {
        found = YES;
        AccountObject *person = fliter.firstObject;
        person.relationShip = kContactIsRefused;
    }
    if (found) {
        [self.tableView reloadData];
    }
}
- (void)didRefuseInviteFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

@end
