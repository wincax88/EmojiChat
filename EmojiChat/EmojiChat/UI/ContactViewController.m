//
//  ContactViewController.m
//  iChat
//
//  Created by michael on 23/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ContactViewController.h"
#import "AddressBookSingleton.h"
#import "AddressBook.h"
#import "AccountObject.h"
#import "ContactCell.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface ContactViewController ()
{
    NSMutableArray  *chatBuddyList;
    NSMutableArray  *sortedBuddyList;
}

@property (nonatomic) CFArrayRef allPeople;
@property (nonatomic) CFIndex nPeople;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UILocalizedIndexedCollation *collation;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    chatBuddyList = [[NSMutableArray alloc] init];
    sortedBuddyList = [[NSMutableArray alloc] init];
    
    [self getInviteUser];
    
    [YBUtility showInfoHUDInView:self.view message:nil];
    
    [AddressBook sharedInstance].addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (&ABAddressBookRequestAccessWithCompletion != NULL) {
        
        ABAddressBookRequestAccessWithCompletion([AddressBook sharedInstance].addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"Error");
                CFRelease(error);
                
                [YBUtility hideInfoHUDInView:self.view];
            }
            else {
                [self asyncReloadData];
            }
        });
    }
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
            if (objects.count > 0) {
                [self.tableView reloadData];
            }
        } else {
            // Log details of the failure
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)loadContacts {
    [chatBuddyList removeAllObjects];
    
    [[AddressBook sharedInstance] checkIfContactDeleted];
    
    self.allPeople = ABAddressBookCopyArrayOfAllPeople([AddressBook sharedInstance].addressBook);
    self.nPeople = ABAddressBookGetPersonCount([AddressBook sharedInstance].addressBook);
    
    for ( int i = 0; i < self.nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( self.allPeople, i );
        AccountObject *person = [[AccountObject alloc] init];
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonLastNameProperty));
        firstName = firstName == nil ? @"" : firstName;
        lastName = lastName == nil ? @"" : lastName;
        person.nick = [NSString stringWithFormat:@"%@%@", firstName, lastName];
        
        ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        NSArray* phoneNumberArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneNumberProperty));
        
        for (int index = 0; index< [phoneNumberArray count]; index++) {
            
            NSString *phoneNumber = [phoneNumberArray objectAtIndex:index];
            
            if ([phoneNumber hasPrefix:@"+86"]) {
                phoneNumber = [phoneNumber substringFromIndex:3];
            }
            //
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (phoneNumber.length < 11) {
                continue;
            }
            NSString *phoneNumberLabel = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phoneNumberProperty, index));
            
            if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel]) {
                
                person.phone = phoneNumber;
                
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                
                person.phone = phoneNumber;
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel]) {
                
                person.phone = phoneNumber;
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneHomeFAXLabel]) {
                
                person.phone = phoneNumber;
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneWorkFAXLabel]) {
                
                person.phone = phoneNumber;
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhoneOtherFAXLabel]) {
                
                person.phone = phoneNumber;
            }
            else if ([phoneNumberLabel isEqualToString:(NSString*)kABPersonPhonePagerLabel]) {
                
                person.phone = phoneNumber;
            }
            else {
                person.phone = phoneNumber;
            }
            if (person.phone.length >= 11) {
                break;
            }
        }
        CFBridgingRelease(phoneNumberProperty);
        
        if (person.phone.length >= 11) { // just using valid phone number
            NSArray *filter = [[ApplicationManager sharedManager].inviteUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", person.phone]];
            if (filter.count > 0) {
                person.relationShip = kContactInvited;
            }
            if (person.relationShip <= 0) {
                NSArray *filter = [[ApplicationManager sharedManager].friendList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"buddy.phone == %@", person.phone]];
                if (filter.count > 0) {
                    FriendObject *friend = filter.firstObject;
                    person.relationShip = kContactIsFriend;
                    person.userid = friend.buddy[PF_USER_PHONE];
                    //person.face = friend.buddy.avatarUrl;
                }
            }
            [chatBuddyList addObject:person];
        }
    }
}

- (void)asyncReloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self loadContacts];
        
        [sortedBuddyList removeAllObjects];
        [sortedBuddyList addObjectsFromArray:[self partitionObjects:chatBuddyList collationStringSelector:@selector(sortByNickName)]];
        [self.tableView reloadData];
        
        [YBUtility hideInfoHUDInView:self.view];
    });
    
}

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    self.collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[self.collation sectionTitles] count];//section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    // create an array to hold the data for each section
    for (int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    // put each object into a section
    for (id object in array)
    {
        NSInteger index = [self.collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    // sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[self.collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

- (void)sendInvite2Phone:(NSString*)phone nick:(NSString*)nick
{
    // add invite phone to invite table
    PFUser *curUser = [PFUser currentUser];
    PFObject *invitee = [PFObject objectWithClassName:PF_INVITE_CLASS_NAME];
    invitee[PF_INVITE_INVITEE_PHONE] = phone;
    invitee[PF_INVITE_INVITEE_NICK] = nick;
    invitee[PF_INVITE_INVITER_PHONE] = curUser[PF_USER_PHONE];
    invitee[PF_INVITE_INVITER_NICK] = curUser[PF_USER_NICKNAME];
    invitee[PF_INVITE_TIME] = [NSDate date];
    [invitee saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
//            [invitee refresh];
            [self didInviteUserWithPhoneSuccess:phone];
        }
        else {
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
    }];
}

- (void)sendAccept2User:(NSString*)userId
{
    // add phone to friend table
    PFUser *curUser = [PFUser currentUser];
    PFObject *friend = [PFObject objectWithClassName:PF_FRIEND_CLASS_NAME];
    friend[PF_FRIEND_MSATER_OBJECT] = curUser;
    friend[PF_FRIEND_BUDDY_OBJECT] = curUser;
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

- (void)sendRefuse2User:(NSString*)userId
{
    [self removeInvite:userId selector:@selector(didRefuseInviteSuccess:)];
}

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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sortedBuddyList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)sortedBuddyList[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    cell.singleSelect = self.singleSelect;
    
    AccountObject *person = sortedBuddyList[indexPath.section][indexPath.row];
    
    [cell setContact:person];
    
    cell.invateBlock = ^(NSString *phone) {
        if (phone.length > 0) {
            // send invite to this phone
            [self sendInvite2Phone:phone nick:person.nick];
        }
    };
    cell.acceptBlock = ^(NSString *userId) {
        if (userId.length > 0) {
            // send invite to this phone
            [self sendAccept2User:userId];
        }
    };
    cell.refuseBlock = ^(NSString *userId) {
        if (userId.length > 0) {
            // send invite to this phone
            [self sendRefuse2User:userId];
        }
    };
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((NSArray *)sortedBuddyList[section]).count ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.singleSelect) {
        AccountObject *person = sortedBuddyList[indexPath.section][indexPath.row];
        if (person.relationShip != kContactIsFriend) {
            if (self.contactSelectBlock) {
                self.contactSelectBlock(person.phone);
                
            }
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self loadMessageDetailViewController:buddy placeholder:[NSString stringWithFormat:@"发送信息给%@",buddy.nickName] hideInput:NO];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;//buddy.canRemove.boolValue;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        /*
         ChatBuddy *buddy = [chatBuddyList objectAtIndex:indexPath.row];
         [[ApplicationManager sharedManager].xmppManager4Chat removeChatMessageFromStorage:buddy.userId];
         [[ApplicationManager sharedManager].xmppManager4Chat removeContactFromStorage:buddy.userId];
         [chatBuddyList removeObject:buddy];
         [[ApplicationManager sharedManager].chatBuddyList removeObject:buddy];
         [tableView reloadData];
         */
    }
}
#pragma mark - http
- (void)didInviteUserWithPhoneSuccess:(NSString*)phones
{
    NSArray *component = [phones componentsSeparatedByString:@","];
    BOOL found = NO;
    for (NSString *phone in component) {
        for (NSArray *section in sortedBuddyList) {
            // change contact status
            NSArray *fliter = [section filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"phone == %@", phone]];
            if (fliter.count > 0) {
                found = YES;
                AccountObject *person = fliter.firstObject;
                person.relationShip = kContactInvited;
                break;
            }
        }
    }
    if (found) {
        [self.tableView reloadData];
    }
}

- (void)didInviteUserWithPhoneFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

- (void)didAcceptInviteSuccess:(NSString*)userId
{
    BOOL found = NO;
    for (NSArray *section in sortedBuddyList) {
        // change contact status
        NSArray *fliter = [section filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"phone == %@", userId]];
        if (fliter.count > 0) {
            found = YES;
            AccountObject *person = fliter.firstObject;
            person.relationShip = kContactIsFriend;
            break;
        }
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
    BOOL found = NO;
    for (NSArray *section in sortedBuddyList) {
        // change contact status
        NSArray *fliter = [section filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"phone == %@", userId]];
        if (fliter.count > 0) {
            found = YES;
            AccountObject *person = fliter.firstObject;
            person.relationShip = kContactIsRefused;
            break;
        }
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
