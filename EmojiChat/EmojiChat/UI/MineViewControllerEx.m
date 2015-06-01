//
//  MineViewControllerEx.m
//  EmojiChat
//
//  Created by michael on 25/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "MineViewControllerEx.h"
#import "NicknameViewController.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import "GKImagePicker.h"
//#import "ManualUplaodManager.h"
#import "MD5.h"
#import "AppDelegate.h"
#import "MineInfoCell.h"
#import "ConfigureViewController.h"
#import "NotificationViewController.h"
#import "ContactViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "AppConstant.h"

@interface MineViewControllerEx ()
<
UITableViewDataSource,
UITableViewDelegate,
GKImagePickerDelegate
>
{
    NSArray *identifierArray;

    NSString            *avatarCacheFile;
    
    NSString            *imageKey;
    
    GKImagePicker       *picker;
    
}

@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onAvatarTouched:(id)sender;

@end

@implementation MineViewControllerEx


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [YBUtility makeRoundForImageView:self.imageUser];
    
    identifierArray = @[@"NickCell", @"BuddyCell",/* @"NewChatCell",*/ @"SettingCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([ApplicationManager sharedManager].confirmList.count > 0) {
        identifierArray = @[@"NickCell", @"ConfirmCell", @"BuddyCell",/* @"NewChatCell",*/ @"SettingCell"];
    }
    else {
        identifierArray = @[@"NickCell", @"BuddyCell", /* @"NewChatCell",*/ @"SettingCell"];
    }
    
    if ([PFUser currentUser]) {
        // request confirm list
        [self getConfirmList];
        [self getInviteUser];
        
        [self refresh];
        
        [self checkNotification];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    [self.tableView reloadData];
    
    PFUser *user = [PFUser currentUser];
    
    [self.imageUser setFile:user[PF_USER_PICTURE]];
    [self.imageUser loadInBackground];
}

- (void)refresh
{
    // request user info from server
    [self requestProfile];
}

- (void)checkNotification
{
    
}

#pragma mark - action
- (IBAction)onAvatarTouched:(id)sender {
    [self loadGKImagePicker];
}

#pragma mark - private
- (void)updateTableView
{
    if ([ApplicationManager sharedManager].confirmList.count > 0) {
        identifierArray = @[@"NickCell", @"ConfirmCell", @"BuddyCell", /* @"NewChatCell",*/ @"SettingCell"];
    }
    else {
        identifierArray = @[@"NickCell", @"BuddyCell", /* @"NewChatCell",*/ @"SettingCell"];
    }
    [self.tableView reloadData];
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
             for (PFObject *object in objects) {
                 FriendObject *friend = [[FriendObject alloc] init];
                 friend.buddy = object[PF_FRIEND_BUDDY_OBJECT];
                 friend.nickName = object[PF_FRIEND_BUDDY_NICKNAME];
                 friend.index = object[PF_FRIEND_BUDDY_INDEX];
                 [[ApplicationManager sharedManager].friendList addObject:friend];
             }
             
         } else {
             // Log details of the failure
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
     }];
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
            
            [self updateTableView];
            
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)requestProfile
{
    if ([PFUser currentUser]) {
        [self updateUI];
    }
    else {
        NSString *account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
        NSString *password = [YBUtility getPasswordWithAccount:account];
        [PFUser logInWithUsername:account password:password];
    }
}

- (void)loadGKImagePicker
{
    if (!picker) {
        picker = nil;
    }
    picker = [[GKImagePicker alloc] init];
    picker.delegate = self;
    picker.cropper.cropSize = CGSizeMake(320.,320.);   // (Optional) Default: CGSizeMake(320., 320.)
    picker.cropper.rescaleImage = YES;                // (Optional) Default: YES
    picker.cropper.rescaleFactor = 2.0;               // (Optional) Default: 1.0
    picker.cropper.dismissAnimated = YES;              // (Optional) Default: YES
    picker.cropper.overlayColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7];  // (Optional) Default: [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7]
    picker.cropper.innerBorderColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.7];   // (Optional) Default: [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7]
    [picker presentPicker:CGRectZero inView:nil];
}

- (void)loadNicknameViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"NicknameViewController"];
    NicknameViewController *controller = [[nv childViewControllers] firstObject];
    PFUser *user = [PFUser currentUser];
    controller.nickname = user[PF_USER_NICKNAME];
    __weak __typeof(self)weakSelf = self;
    // __weak ForgotPasswordViewController *weakController = controller;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.saveBlock = ^(NSString *nickName){
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [weakSelf.tableView reloadData];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}
// loadConfirmViewController
- (void)loadConfirmViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmViewController"];
    ConfigureViewController *controller = [[nv childViewControllers] firstObject];
    //    __weak __typeof(self)weakSelf = self;
    
    //    controller.backBlock = ^{
    //        [weakSelf.navigationController popViewControllerAnimated:YES];
    //    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)loadConfigureViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ConfigureViewController"];
    ConfigureViewController *controller = [[nv childViewControllers] firstObject];
    __weak __typeof(self)weakSelf = self;
    
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.logoutBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:NO];
        
        [XMainViewController loadLoginViewController];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

// NotificationViewController
- (void)loadNotificationViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    NotificationViewController *controller = [[nv childViewControllers] firstObject];
    /*__weak __typeof(self)weakSelf = self;
     
     controller.backBlock = ^{
     [weakSelf.navigationController popViewControllerAnimated:YES];
     };
     controller.logoutBlock = ^{
     [weakSelf.navigationController popViewControllerAnimated:NO];
     
     [XMainViewController loadLoginViewController];
     };*/
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

// ContactViewController
- (void)loadContactViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"ContactViewController"];
    ContactViewController *controller = [[nv childViewControllers] firstObject];
    /*__weak __typeof(self)weakSelf = self;
     
     controller.backBlock = ^{
     [weakSelf.navigationController popViewControllerAnimated:YES];
     };
     controller.logoutBlock = ^{
     [weakSelf.navigationController popViewControllerAnimated:NO];
     
     [XMainViewController loadLoginViewController];
     };*/
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [identifierArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [identifierArray objectAtIndex:indexPath.row];
    MineInfoCell *cell = (MineInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cellIdentifier isEqualToString:@"NickCell"]) {
        PFUser *user = [PFUser currentUser];
        NSString *nickName = user[PF_USER_NICKNAME];
        if (nickName.length <= 0) {
            cell.badgeView.hidden = NO;
            cell.valueLabel.text = nickName;
        }
        else {
            cell.badgeView.hidden = YES;
            cell.valueLabel.text = nickName;
        }
    }
    else if ([cellIdentifier isEqualToString:@"ConfirmCell"]) {
        if ([ApplicationManager sharedManager].confirmList.count > 0) {
            cell.badgeView.hidden = NO;
        }
        else {
            cell.badgeView.hidden = YES;
        }
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // @"NickCell", @"BuddyCell", @"NewChatCell", @"SettingCell"
    NSString *cellIdentifier = [identifierArray objectAtIndex:indexPath.row];
    if ([cellIdentifier isEqualToString:@"NickCell"]) {
        [self loadNicknameViewController];
    }
    else if ([cellIdentifier isEqualToString:@"BuddyCell"]) {
        // load
        [self loadContactViewController];
    }
    else if ([cellIdentifier isEqualToString:@"NewChatCell"]) {
        // load
        [self loadNotificationViewController];
    }
    else if ([cellIdentifier isEqualToString:@"SettingCell"]) {
        // load
        [self loadConfigureViewController];
    }
    else if ([cellIdentifier isEqualToString:@"ConfirmCell"]) // ConfirmCell
    {
        [self loadConfirmViewController];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - GKImagePicker delegate methods

- (void)imagePickerDidFinish:(GKImagePicker *)imagePicker withImage:(UIImage *)image {
    // show hud
    [YBUtility showInfoHUDInView:self.view message:nil];
    
    UIImage *picture = [YBUtility scaleImage:image toSize:CGSizeMake(280, 280)];
    UIImage *thumbnail = [YBUtility scaleImage:image toSize:CGSizeMake(60, 60)];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.7)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
         else {
             PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
             [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (error != nil) {
                      [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                  }
                  else {
                      PFUser *user = [PFUser currentUser];
                      user[PF_USER_PICTURE] = filePicture;
                      user[PF_USER_THUMBNAIL] = fileThumbnail;
                      [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (error != nil) {
                               [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                           }
                           else {
                               [YBUtility showInfoHUDInView:self.view message:@"头像上传成功"];
                               self.imageUser.image = picture;
                           }
                       }];
                  }
              }];
         }
     }];
}

@end
