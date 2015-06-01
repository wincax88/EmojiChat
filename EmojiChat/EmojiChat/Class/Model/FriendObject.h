//
//  FriendObject.h
//  EmojiChat
//
//  Created by michael on 15/5/31.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

@interface FriendObject : NSObject

@property (strong, nonatomic) PFUser    *buddy;
@property (strong, nonatomic) NSNumber  *index;
@property (strong, nonatomic) NSString  *nickName;

@end
