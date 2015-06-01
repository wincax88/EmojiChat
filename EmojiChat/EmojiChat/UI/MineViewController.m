//
//  MineViewController.m
//  iChat
//
//  Created by michael on 21/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "MineViewController.h"
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
#import "AppConstant.h"
#import "push.h"


@interface MineViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
GKImagePickerDelegate
//ManualUplaodManagerDelegate
>
{
    NSArray *identifierArray;
    
    //    ParentObject        *parent;
    
    NSString            *avatarCacheFile;
    
    NSString            *imageKey;
    
    GKImagePicker       *picker;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onAvatarTouched:(id)sender;
- (IBAction)onBackTouched:(id)sender;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [YBUtility makeRoundForImageView:self.avatarImageView];
    
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
    
    // request confirm list
    [self getConfirmList];
    [self getInviteUser];
    
    [self refresh];
    
    [self checkNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
//    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
//    [[ApplicationManager sharedManager].manualUplaodManager unregisterDelegate:self];
    [super viewDidDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    [self.tableView reloadData];
    
    PFUser *user = [PFUser currentUser];
    
    PFFile *file = user[PF_USER_THUMBNAIL];
    if (file && [file isKindOfClass:[PFFile class]]) {
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (!error) {
                 self.avatarImageView.image = [UIImage imageWithData:imageData];
             }
             else {
                 [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
             }
         }];
    }
    /*
    // set up our query for a User object
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_PHONE notEqualTo:user[PF_USER_PHONE]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             PFUser *curUser = objects.firstObject;
             PFObject *anotherPhoto = curUser[PF_USER_THUMBNAIL];
             PFFile *userImageFile = anotherPhoto[@"image"];
             [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                 if (!error) {
                     self.avatarImageView.image = [UIImage imageWithData:imageData];
                 }
                 else {
                     [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
                 }
             }];
         }
         else
         {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
     }];*/

    //if ([ApplicationManager sharedManager].account.face.length > 0) {
    //    [YBUtility setImageView:self.avatarImageView withURLString:[ApplicationManager sharedManager].account.face placeHolder:nil];
    //}
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

- (IBAction)onBackTouched:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

#pragma mark - private
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
    //[query includeKey:PF_FRIEND_BUDDY_INDEX];
    //[query includeKey:PF_FRIEND_BUDDY_NICKNAME];
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
                buddy.phoneNumber = friendUser[PF_USER_PHONE];
                 */
                [[ApplicationManager sharedManager].friendList addObject:friendUser];
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
            [self updateUI];
            //[self didGetConfirmListSuccess:nil];
            
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)requestProfile
{
    if ([PFUser currentUser]) {
        //PFUser *user = [PFUser currentUser];
        //AccountObject *account = [ApplicationManager sharedManager].account;
        //account.face = user[PF_USER_THUMBNAIL];
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
    controller.nickname = [ApplicationManager sharedManager].account.nick;
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
        
        ParsePushUserResign();
        
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
        [ApplicationManager sharedManager].account.nick = user[PF_USER_NICKNAME];
        if ([ApplicationManager sharedManager].account.nick.length <= 0) {
            cell.badgeView.hidden = NO;
            cell.valueLabel.text = [ApplicationManager sharedManager].account.nick;
        }
        else {
            cell.badgeView.hidden = YES;
            cell.valueLabel.text = [ApplicationManager sharedManager].account.nick;
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
    UIImage *scaledImage = [YBUtility scaleImageTo1024:image];
    // show hud
    [YBUtility showInfoHUDInView:self.view message:nil];
    
    NSData *imaegData = UIImagePNGRepresentation(scaledImage);
    imageKey = [MD5 md5NSData:imaegData];
    
    // upload image file
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *filePicture = [PFFile fileWithName:@"picture.png" data:imaegData];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.png" data:imaegData];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
     }];
    
    NSString *account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
    NSString *password = [YBUtility getPasswordWithAccount:account];
    PFUser *user = [PFUser logInWithUsername:account password:password];
    user[PF_USER_PICTURE] = filePicture;
    user[PF_USER_THUMBNAIL] = fileThumbnail;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
         }
         else {
             // update UI
             [self updateUI];
         }
     }];
    /*
    NSString *fileName = [NSString stringWithFormat:@"%@_avatar.png", [ApplicationManager sharedManager].account.userid];
    PFFile *imageFile = [PFFile fileWithName:fileName data:imaegData];
    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
    userPhoto[@"image"] = imageFile;
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSError *saveError;
            NSString *account = [ApplicationManager sharedManager].localSettingData.lastLoginAccount;
            NSString *password = [YBUtility getPasswordWithAccount:account];
            PFUser *user = [PFUser logInWithUsername:account password:password];
            user[PF_USER_THUMBNAIL] = userPhoto;
            if ([user save:&saveError]) {
                // update UI
                [self updateUI];
            }
            else {
                [YBUtility showErrorMessageInView:self.view message:saveError.localizedDescription errorCode:nil];
            }
        }
        else {
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];*/
    

}


# pragma mark - ManualUplaodManagerDelegate
/*
- (void)didManualUploadSuccess:(NSDictionary*)userData
{
    if (![imageKey isEqual:[userData objectForKey:@"imageKey"]]) {
        return;
    }
    NSString *imageUrl = [userData objectForKey:@"imageURL"];
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    [[ApplicationManager sharedManager].httpClientHandler setFace:imageUrl];
    
}

- (void)didManualUploadFailed:(NSError*)error userData:(NSDictionary*)userData
{
    if (![imageKey isEqual:[userData objectForKey:@"imageKey"]]) {
        return;
    }
    [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:[NSNumber numberWithInt:error.code]];
}

#pragma mark - HttpClientHandlerDelegate

- (void)didGetUserInfoSuccess
{
    [self updateUI];
}

- (void)didGetUserInfoFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didSetFaceSuccess:(NSDictionary*)userData
{
    [YBUtility hideInfoHUDInView:self.view];
    [ApplicationManager sharedManager].account.face = [userData objectForKey:@"face"];
    [self updateUI];
}

- (void)didSetFaceFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didGetConfirmListSuccess:(NSDictionary*)userData
{
    if ([ApplicationManager sharedManager].confirmList.count > 0) {
        identifierArray = @[@"NickCell", @"ConfirmCell", @"BuddyCell",  @"SettingCell"];
    }
    else {
        identifierArray = @[@"NickCell", @"BuddyCell",  @"SettingCell"];
    }
    [self.tableView reloadData];
}

- (void)didGetConfirmListFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}*/

@end
