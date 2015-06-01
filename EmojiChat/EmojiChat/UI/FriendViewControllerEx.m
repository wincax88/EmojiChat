//
//  FriendViewControllerEx.m
//  EmojiChat
//
//  Created by michael on 15/5/26.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import "FriendViewControllerEx.h"
#import "FriendCell.h"
#import "ContactObject.h"
#import "YBUtility.h"
#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "ContactViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "EmojiKeyBoardViewController.h"
#import "UIAlertView+Blocks.h"
#import <SMS_SDK/SMS_SDK.h>


@interface FriendViewControllerEx ()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>
{
    NSArray *contactsArray;
    EmojiKeyBoardViewController *keyBoard;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation FriendViewControllerEx

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contactsArray = [ApplicationManager sharedManager].friendList;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 1.5; //seconds
    //    longPressGesture.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBarHidden = NO;
    
    [self getFriendList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)showKeyBoard4User:(PFUser*)user
{
    //[self.textField becomeFirstResponder];
    if (keyBoard) {
        [keyBoard showKeyBoard];
        return;
    }
    keyBoard = [[EmojiKeyBoardViewController alloc] initWithNibName:@"EmojiKeyBoardViewController" bundle:nil];
    [self addChildViewController:keyBoard];
    [self.view addSubview:keyBoard.view];
    __weak EmojiKeyBoardViewController *weakKeyBoard = keyBoard;
    __weak __typeof(self) weakSelf = self;
    keyBoard.backTouchBlock = ^ { // hide key board
        [weakKeyBoard hideKeyBoard];
        //[weakKeyBoard.view removeFromSuperview];
        //[weakKeyBoard removeFromParentViewController];
    };
    keyBoard.emojiSelectedBlock = ^ (NSString *emoji) {
        [weakKeyBoard hideKeyBoard];
        // send emoji to friend
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEmoji:emoji to:user];
        });
    };
}

- (void)getFriendList
{
    PFUser *curUser = [PFUser currentUser];
    if (!curUser) {
        [UIAlertView showWithTitle:nil message:@"请重新登录" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [XMainViewController loadLoginViewController];
        }];
        return;
    }
    // get friends in friend table
    PFQuery *query = [PFQuery queryWithClassName:PF_FRIEND_CLASS_NAME];
    [query whereKey:PF_FRIEND_MSATER_OBJECT equalTo:curUser];
    [query includeKey:PF_FRIEND_BUDDY_OBJECT];
    //[query includeKey:PF_FRIEND_BUDDY_INDEX];
    //[query includeKey:PF_FRIEND_BUDDY_NICKNAME];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error) {
             //
             [[ApplicationManager sharedManager].friendList removeAllObjects];
             for (PFObject *object in objects) {
                 FriendObject *friend = [[FriendObject alloc] init];
                 friend.buddy = object[PF_FRIEND_BUDDY_OBJECT];
                 friend.nickName = object[PF_FRIEND_BUDDY_NICKNAME];
                 friend.index = object[PF_FRIEND_BUDDY_INDEX];
                 /*
                  ChatBuddy *buddy = [[ChatBuddy alloc] init];
                  buddy.userId = friendUser[PF_USER_PHONE];
                  buddy.nickName = friendUser[PF_USER_NICKNAME];;
                  // buddy.avatarUrl = [item objectForKey:@"face"];
                  buddy.phoneNumber = friendUser[PF_USER_PHONE];
                  */
                 [[ApplicationManager sharedManager].friendList addObject:friend];
             }
             
             if (objects.count > 0) {
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self.collectionView reloadData];
                 });
             }
         } else {
             // Log details of the failure
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
     }];
}

// send emoji to friend
- (void)sendEmoji:(NSString*)emoji to:(PFUser*)buddy
{
    [[ApplicationManager sharedManager].notificationManager sendPush:emoji to:buddy];
    
}

- (void)invite
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ContactViewController"];
    ContactViewController *controller = [[nv childViewControllers] firstObject];
    controller.singleSelect = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
    controller.contactSelectBlock = ^ (NSString *phone) {
        [self.navigationController popViewControllerAnimated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self invite:phone];
        });
    };
}

- (void)invite:(NSString*)phone
{
    [YBUtility showInfoHUDInView:self.view message:nil];
    // check phone is an existed account,and add it
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_PHONE equalTo:phone];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [YBUtility hideInfoHUDInView:self.view];
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
//                        [self removeInvite:userId selector:@selector(didAcceptInviteSuccess:)];
                    }
                    else {
                        [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                    }
                }];
            }
            else { // else , send sms
                NSString *message = @"请下载";
                [SMS_SDK sendSMS:phone AndMessage:message];
            }
        }
        else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
    
}

#pragma mark - UILongPressGestureRecognizer
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint pos = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pos];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSArray *filter = [contactsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index = %@", [NSNumber numberWithInteger:indexPath.row]]];
        if (filter.count > 0) {
            FriendObject *friend = [filter firstObject];
            NSString *phone = friend.buddy[PF_USER_PHONE];
            if (phone.length > 0) {
                [YBUtility makePhoneCall:phone];
            }
        }
    }
    else {
        NSLog(@"gestureRecognizer.state = %d", (int)gestureRecognizer.state);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    cell.imageView.layer.borderColor = [[UIColor colorWithHue:indexPath.row/12.0f saturation:0.8f brightness:0.8f alpha:1.0f] CGColor];
    cell.imageView.layer.borderWidth = 2.0f;
    
    NSArray *filter = [contactsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index = %@", [NSNumber numberWithInteger:indexPath.row]]];
    if (filter.count > 0) {
        FriendObject *friend = [filter firstObject];
        [cell setFriend:friend];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"icon_avatar_man"];
        cell.nickLabel.text =  @"+";
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *filter = [contactsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index = %@", [NSNumber numberWithInteger:indexPath.row]]];
    if (filter.count > 0) {
        FriendObject *friend = [filter firstObject];
        [self showKeyBoard4User:friend.buddy];
    }
    else {
        [self invite];
    }
}

@end
