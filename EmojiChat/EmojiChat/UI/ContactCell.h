//
//  ContactCell.h
//  iChat
//
//  Created by michael on 23/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^InvaieTouchBlock) (NSString *phone);
typedef void (^AcceptTouchBlock) (NSString *userId);
typedef void (^RefuseTouchBlock) (NSString *userId);

@class AccountObject;

@interface ContactCell : UITableViewCell

@property (copy) InvaieTouchBlock invateBlock;
@property (copy) AcceptTouchBlock acceptBlock;
@property (copy) RefuseTouchBlock refuseBlock;

@property (strong, nonatomic) IBOutlet UILabel  *nickLabel;
@property (strong, nonatomic) IBOutlet UILabel  *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel  *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) IBOutlet UIButton *refuseButton;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

- (IBAction)onInviteTouched:(id)sender;
- (IBAction)onAcceptTouched:(id)sender;
- (IBAction)onRefuseTouched:(id)sender;

- (void)setContact:(AccountObject*)contact;

@end
