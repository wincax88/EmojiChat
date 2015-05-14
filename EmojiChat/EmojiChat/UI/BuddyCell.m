//
//  BuddyCell.m
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "BuddyCell.h"
#import "YBUtility.h"
#import "ChatBuddy.h"
#import "CommonDefine.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@implementation BuddyCell

- (void)awakeFromNib {
    // Initialization code
    [YBUtility makeRoundForImageView:self.iconImageView];
    [YBUtility makeRoundForView:self.badgeView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setChatBuddy:(PFUser*)buddy
{
    self.buddy = buddy;
    PFFile *file = buddy[PF_USER_THUMBNAIL];
    if ([file isKindOfClass:[PFFile class]]) {
        [YBUtility setImageView:self.iconImageView withURLString:file.url placeHolder:@"icon_avatar_man"];
    }
    else {
        [YBUtility setImageView:self.iconImageView withURLString:nil placeHolder:@"icon_avatar_man"];
    }
    self.badgeView.hidden = YES;
    NSString *nickName = buddy[PF_USER_NICKNAME];
    self.titleLabel.text = [nickName length] > 0 ? nickName : buddy[PF_USER_PHONE];
    //self.messageLabel.text = buddy.latestMessage;
    //if ([buddy.latestMessage length] > 0) {
    //    self.timeLabel.text = [YBUtility getFormatDateTime:buddy.latestDate.doubleValue];
    //}
    //else {
    //    self.timeLabel.text = nil;
    //}
}

#pragma mark - action
- (IBAction)onAvatarTouched:(id)sender {
    if (self.avatarTouchBlock) {
        self.avatarTouchBlock(self.buddy);
    }
    
}

@end
