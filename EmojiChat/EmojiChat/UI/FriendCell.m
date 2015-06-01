//
//  FriendCell.m
//  EmojiChat
//
//  Created by michael on 15/5/26.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import "FriendCell.h"
#import "YBUtility.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "FriendObject.h"

@implementation FriendCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [YBUtility makeRoundForImageView:self.imageView];
    
}

- (void)setFriend:(FriendObject*)friend
{
    PFFile *file = friend.buddy[PF_USER_THUMBNAIL];
    if ([file isKindOfClass:[PFFile class]]) {
        [YBUtility setImageView:self.imageView withURLString:file.url placeHolder:@"icon_avatar_man"];
    }
    else {
        [YBUtility setImageView:self.imageView withURLString:nil placeHolder:@"icon_avatar_man"];
    }
    NSString *nickName = friend.nickName;
    self.nickLabel.text = [nickName length] > 0 ? nickName : friend.buddy[PF_USER_PHONE];
}

@end
