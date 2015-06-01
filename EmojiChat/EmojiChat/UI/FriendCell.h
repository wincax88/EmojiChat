//
//  FriendCell.h
//  EmojiChat
//
//  Created by michael on 15/5/26.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;
@class FriendObject;

@interface FriendCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nickLabel;

- (void)setFriend:(FriendObject*)friend;

@end
