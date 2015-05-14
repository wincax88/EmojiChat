//
//  ContactCell.m
//  iChat
//
//  Created by michael on 23/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ContactCell.h"
#import "AccountObject.h"
#import "YBUtility.h"

@interface ContactCell()
{
    NSString *userId;
}

@end
@implementation ContactCell

- (void)awakeFromNib {
    // Initialization code
    if (_avatarImageView) {
        [YBUtility makeRoundForImageView:_avatarImageView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onInviteTouched:(id)sender
{
    if (self.invateBlock) {
        self.invateBlock(self.phoneLabel.text);
    }
}

- (IBAction)onAcceptTouched:(id)sender
{
    if (self.acceptBlock) {
        self.acceptBlock(userId);
    }
}

- (IBAction)onRefuseTouched:(id)sender
{
    if (self.refuseBlock) {
        self.refuseBlock(userId);
    }
}

- (void)setContact:(AccountObject*)contact
{
    userId = [NSString stringWithFormat:@"%@", contact.userid];
    
    self.statusLabel.hidden = YES;
    self.addButton.hidden = YES;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    
    self.nickLabel.text = contact.nick;
    self.phoneLabel.text = contact.phone;
    
    
    if (contact.relationShip == kContactInvited) {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"已邀请";
    }
    else if (contact.relationShip == kContactIsFriend) {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"已添加";
    }
    else if (contact.relationShip == kContactIsInvitee) {
        self.acceptButton.hidden = NO;
        self.refuseButton.hidden = NO;
    }
    else if (contact.relationShip == kContactIsRefused) {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"已拒绝";
    }
    else {
        self.addButton.hidden = NO;
    }
    
    if (self.avatarImageView) {
        [YBUtility setImageView:self.avatarImageView withURLString:contact.face placeHolder:nil];
    }
}

@end
