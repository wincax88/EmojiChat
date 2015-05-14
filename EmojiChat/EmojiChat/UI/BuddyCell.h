//
//  BuddyCell.h
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

typedef void (^AvatarTouchBlock) (PFUser *buddy);


@interface BuddyCell : UITableViewCell

@property(copy) AvatarTouchBlock avatarTouchBlock;

@property (strong, nonatomic) PFUser *buddy;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UIView *badgeView;

- (IBAction)onAvatarTouched:(id)sender;

- (void)setChatBuddy:(PFUser*)buddy;

@end
