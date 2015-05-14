//
//  ChatBuddy.m
//  iStudent
//
//  Created by michael on 28/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ChatBuddy.h"

@implementation ChatBuddy

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
}


#pragma mark - NSCoding

-(id) initWithCoder: (NSCoder*) coder {
    if (self = [super init]) {
        
        self.userId         = [coder decodeObjectForKey:@"userId"];
        self.nickName       = [coder decodeObjectForKey:@"nickName"];
        self.avatarUrl      = [coder decodeObjectForKey:@"avatarUrl"];
        self.latestMessage  = [coder decodeObjectForKey:@"latestMessage"];
        self.latestDate     = [coder decodeObjectForKey:@"latestDate"];
        self.hasUnread      = [coder decodeObjectForKey:@"hasUnread"];
        
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    [coder encodeObject:self.latestMessage forKey:@"latestMessage"];
    [coder encodeObject:self.latestDate forKey:@"latestDate"];
    [coder encodeObject:self.hasUnread forKey:@"hasUnread"];
    
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    ChatBuddy *buddy = [[ChatBuddy alloc] init];
    
    buddy.userId            = self.userId;
    buddy.nickName          = self.nickName;
    buddy.avatarUrl         = self.avatarUrl;
    buddy.latestMessage     = self.latestMessage;
    buddy.latestDate        = self.latestDate;
    buddy.hasUnread         = self.hasUnread;
    
    return buddy;
}

- (NSString*)sortByNickName {
    return _nickName;
}

@end
