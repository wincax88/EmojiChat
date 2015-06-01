//
//  ConfigureObject.m
//  iStudent
//
//  Created by michael on 27/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ConfigureObject.h"
#import "Assistant.h"

@implementation ConfigureObject
/*
- (id)init
{
    self = [super init];
    if (self) {
        _assistants = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - NSCoding

-(id) initWithCoder: (NSCoder*) coder {
    if (self = [super init]) {
        self.chat_xmpp      = [coder decodeObjectForKey:@"chat_xmpp"];
        self.chat_xmpp_port = [coder decodeObjectForKey:@"chat_xmpp_port"];
        self.cs_face        = [coder decodeObjectForKey:@"cs_face"];
        self.cs_id          = [coder decodeObjectForKey:@"cs_id"];
        self.cs_nick        = [coder decodeObjectForKey:@"cs_nick"];
        self.pm_face        = [coder decodeObjectForKey:@"pm_face"];
        self.pm_id          = [coder decodeObjectForKey:@"pm_id"];
        self.pm_nick        = [coder decodeObjectForKey:@"pm_nick"];
        self.quiz_len       = [coder decodeObjectForKey:@"quiz_len"];
        self.sys_face       = [coder decodeObjectForKey:@"sys_face"];
        self.sys_id         = [coder decodeObjectForKey:@"sys_id"];
        self.sys_nick       = [coder decodeObjectForKey:@"sys_nick"];
        self.update         = [coder decodeObjectForKey:@"update"];
        self.download_pub   = [coder decodeObjectForKey:@"download_pub"];
        self.gift_center    = [coder decodeObjectForKey:@"gift_center"];
        self.assistants     = [coder decodeObjectForKey:@"assistants"];
    }
    return self;
}

- (void)setChat_xmpp:(NSString *)chat_xmpp
{
    _chat_xmpp = nil;
    if (chat_xmpp) {
        NSRange range = [chat_xmpp rangeOfString:@":"];
        if (range.location != NSNotFound) {
            _chat_xmpp = [NSString stringWithString:[chat_xmpp substringToIndex:range.location]];
            _chat_xmpp_port = [NSString stringWithString:[chat_xmpp substringFromIndex:range.location+1]];
        }
        else {
            _chat_xmpp = [NSString stringWithString:chat_xmpp];
        }
    }
}

- (void)setAssistants:(NSMutableArray *)assistants
{
    [_assistants removeAllObjects];
    
    for (NSDictionary *item in assistants) {
        Assistant *assistant = [[Assistant alloc] init];
        for (NSString *key in [item allKeys]) {
            if ([assistant respondsToSelector:NSSelectorFromString(key)]) {
                [assistant setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        [_assistants addObject:assistant];
    }
}

-(void) encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:self.chat_xmpp forKey:@"chat_xmpp"];
    [coder encodeObject:self.chat_xmpp_port forKey:@"chat_xmpp_port"];
    [coder encodeObject:self.cs_face forKey:@"cs_face"];
    [coder encodeObject:self.cs_id forKey:@"cs_id"];
    [coder encodeObject:self.cs_nick forKey:@"cs_nick"];
    [coder encodeObject:self.pm_face forKey:@"pm_face"];
    [coder encodeObject:self.pm_id forKey:@"pm_id"];
    [coder encodeObject:self.pm_nick forKey:@"pm_nick"];
    [coder encodeObject:self.quiz_len forKey:@"quiz_len"];
    [coder encodeObject:self.sys_face forKey:@"sys_face"];
    [coder encodeObject:self.sys_id forKey:@"sys_id"];
    [coder encodeObject:self.sys_nick forKey:@"sys_nick"];
    [coder encodeObject:self.update forKey:@"update"];
    [coder encodeObject:self.download_pub forKey:@"download_pub"];
    [coder encodeObject:self.gift_center forKey:@"gift_center"];
    [coder encodeObject:self.assistants forKey:@"assistants"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    ConfigureObject *configure = [[ConfigureObject alloc] init];
    
    configure.chat_xmpp     = self.chat_xmpp;
    configure.chat_xmpp_port     = self.chat_xmpp_port;
    configure.cs_face       = self.cs_face;
    configure.cs_id         = self.cs_id;
    configure.cs_nick       = self.cs_nick;
    configure.pm_face       = self.pm_face;
    configure.pm_id         = self.pm_id;
    configure.pm_nick       = self.pm_nick;
    configure.quiz_len      = self.quiz_len;
    configure.sys_face      = self.sys_face;
    configure.sys_id        = self.sys_id;
    configure.sys_nick      = self.sys_nick;
    configure.update        = self.update;
    configure.download_pub  = self.download_pub;
    configure.gift_center   = self.gift_center;
    configure.assistants    = self.assistants;
    
    return configure;
}
*/
@end
