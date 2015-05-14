//
//  YoViewController.m
//  iChat
//
//  Created by michael on 27/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "YoViewController.h"
#import "BuddyCell.h"
#import "ContactObject.h"
#import "YBUtility.h"
#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "ContactViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface YoViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray *contactsArray;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)onInviteTouched:(id)sender;

@end

@implementation YoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    contactsArray = [ApplicationManager sharedManager].friendList;

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 2.0; //seconds
//    longPressGesture.delegate = self;
    [self.tableView addGestureRecognizer:longPressGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
    
    [self getFriendList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // hide badge
//    [XMainViewController setBadgeValue:nil forIndex:kTabIndexMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private

- (void)getFriendList
{
    PFUser *curUser = [PFUser currentUser];
    if (!curUser) {
        return;
    }
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
            for (PFObject *object in objects) {
                PFUser *friendUser = object[PF_FRIEND_BUDDY_OBJECT];
                /*
                ChatBuddy *buddy = [[ChatBuddy alloc] init];
                buddy.userId = friendUser[PF_USER_PHONE];
                buddy.nickName = friendUser[PF_USER_NICKNAME];;
                // buddy.avatarUrl = [item objectForKey:@"face"];
                buddy.phoneNumber = friendUser[PF_USER_PHONE];
                 */
                [[ApplicationManager sharedManager].friendList addObject:friendUser];
            }
            
            if (objects.count > 0) {
                [self didGetFriendsSuccess];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
//    if ([ApplicationManager sharedManager].account.userid.intValue > 0) {
//        [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
//        [[ApplicationManager sharedManager].httpClientHandler getFriends];
//    }
}

- (void)loadMessageDetailViewController:(NSString*)partner title:(NSString*)title placeholder:(NSString*)placeholder hideInput:(BOOL)hideInput
{
//    [XMainViewController showChatViewController:self.navigationController buddy:partner title:title placeholder:placeholder hideInput:hideInput];
}

// send hi to friend
- (void)sendHi2:(PFUser*)buddy
{
    [[ApplicationManager sharedManager].notificationManager sendPush:@"Hello" to:buddy];
/*
#if (USE_PARSE)
    [[ApplicationManager sharedManager].notificationManager sendPush:@"Hello"];
    
#else
    // send to server
    NSString *audioFile = @"hello.wav";
    NSString *message = @"Hello";
    NSArray *filter = [[ApplicationManager sharedManager].quickChatGroups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"message like %@", message]];
    if (filter.count > 0) {
        NSDictionary *item = filter.firstObject;
        audioFile = [item objectForKey:@"audio"];;
    }
    NSString *userIds = buddy.userId;
    
    NSString *nick = [ApplicationManager sharedManager].account.nick;
    if (nick.length <= 0) {
        nick = [ApplicationManager sharedManager].account.phone;
    }
    NSString* message2 = [NSString stringWithFormat:@"%@ ：%@", nick ,message];
    
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    [[ApplicationManager sharedManager].httpClientHandler sendMessage:message2 to:userIds audio:audioFile time:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];
#endif
 */
}

- (void)sendMessage:(NSString*)message to:(NSArray *)buddyArray
{
    if (buddyArray.count <= 0 || message.length <= 0) {
        return;
    }
    // send via xmpp
//    for (ChatBuddy *buddy in buddyArray) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            // send message to buddy
//            [[ApplicationManager sharedManager].xmppManager4Chat sendTextMessage:message to:buddy.userId];
//        });
//    }
    // send to server
    NSString *audioFile = @"common.mp3";
    NSArray *filter = [[ApplicationManager sharedManager].quickChatGroups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"message like %@", message]];
    if (filter.count > 0) {
        NSDictionary *item = filter.firstObject;
        audioFile = [item objectForKey:@"audio"];;
    }
    NSString *userIds = [[NSString alloc] init];
    for (ChatBuddy *buddy in buddyArray) {
        if (userIds.length > 0) {
            userIds = [userIds stringByAppendingString:@","];
        }
        userIds = [userIds stringByAppendingString:buddy.userId];
    }
    
    NSString *nick = [ApplicationManager sharedManager].account.nick;
    if (nick.length <= 0) {
        nick = [ApplicationManager sharedManager].account.phone;
    }
    NSString* message2 = [NSString stringWithFormat:@"%@ ：%@", nick ,message];
    
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    [[ApplicationManager sharedManager].httpClientHandler sendMessage:message2 to:userIds audio:audioFile time:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];
}

#pragma mark - public
- (void)refresh
{
#ifdef DEBUG
    NSLog(@"refresh");
#endif
    
    [self.tableView reloadData];
    
}

- (void)checkNotification
{
}

#pragma mark - action
- (IBAction)onInviteTouched:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ContactViewController"];
    ContactViewController *controller = [[nv childViewControllers] firstObject];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([contactsArray count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BuddyCell *cell = (BuddyCell*)[tableView dequeueReusableCellWithIdentifier:@"BuddyCell"];
    if (indexPath.row < contactsArray.count) {
        PFUser *buddy = [contactsArray objectAtIndex:indexPath.row];
        [cell setChatBuddy:buddy];
        cell.iconImageView.hidden = NO;
    }
    else {
        cell.iconImageView.hidden = YES;
        cell.titleLabel.text =  @"+";
    }
    cell.contentView.backgroundColor = [UIColor colorWithHue:indexPath.row/10.0f*1.0f saturation:0.8f brightness:0.5f alpha:1.0f];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < contactsArray.count) {
        PFUser *buddy = [contactsArray objectAtIndex:indexPath.row];
        
//    [self loadMessageDetailViewController:buddy.userId title:buddy.nickName placeholder:@"" hideInput:NO];
        [self sendHi2:buddy];
    }
    else {
        [self onInviteTouched:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Http

- (void)didGetFriendsSuccess
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didGetFriendsFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didSendMessageSuccess:(NSString*)senders time:(NSNumber*)timestamp
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [YBUtility showInfoHUDInView:self.view message:@"发送成功"];
}

- (void)didSendMessageFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

#pragma mark - UILongPressGestureRecognizer
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint pos = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        PFUser *buddy = [contactsArray objectAtIndex:indexPath.row];
        NSString *phone = buddy[PF_USER_PHONE];
        if (phone.length > 0) {
            [YBUtility makePhoneCall:phone];
        }
        /*
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.isHighlighted) {
//            NSLog(@"long press on table view at section %d row %d", indexPath.section, indexPath.row);
        }*/
    }
    else {
        NSLog(@"gestureRecognizer.state = %d", (int)gestureRecognizer.state);
    }
}

@end
