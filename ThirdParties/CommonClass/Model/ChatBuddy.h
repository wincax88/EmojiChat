//
//  ChatBuddy.h
//  iStudent
//
//  Created by michael on 28/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatBuddy : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* avatarUrl;
@property (nonatomic, strong) NSString* phoneNumber;

@property (nonatomic, strong) NSString* latestMessage;
@property (nonatomic, strong) NSNumber* latestDate;
@property (nonatomic, strong) NSNumber* hasUnread;
@property (nonatomic, strong) NSNumber* canRemove;

@property (assign, readwrite) BOOL checked;

@end
