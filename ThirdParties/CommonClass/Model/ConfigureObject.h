//
//  ConfigureObject.h
//  iStudent
//
//  Created by michael on 27/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigureObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString* chat_xmpp;
@property (nonatomic, strong) NSString* chat_xmpp_port;
@property (nonatomic, strong) NSString* cs_face;
@property (nonatomic, strong) NSString* cs_id;
@property (nonatomic, strong) NSString* cs_nick;
@property (nonatomic, strong) NSString* pm_face;
@property (nonatomic, strong) NSString* pm_id;
@property (nonatomic, strong) NSString* pm_nick;
@property (nonatomic, strong) NSNumber* quiz_len;
@property (nonatomic, strong) NSString* sys_face;
@property (nonatomic, strong) NSString* sys_id;
@property (nonatomic, strong) NSString* sys_nick;
@property (nonatomic, strong) NSNumber* update;
@property (nonatomic, strong) NSString* download_pub;
@property (nonatomic, strong) NSString* gift_center;
@property (nonatomic, strong) NSNumber* hide_order;
@property (nonatomic, strong) NSNumber* use_apple_iap;
@property (nonatomic, strong) NSString* test_room;          // for student xmpp and mcu
@property (nonatomic, strong) NSString* lesson_xmpp;        // xmpp ip for whiteboard
@property (nonatomic, strong) NSString* lesson_webrtc;      // mcu ip for whiteboard

@property (nonatomic, strong) NSString* activity_url;
@property (nonatomic, strong) NSNumber* activity_time;

//assistant
@property (nonatomic, strong) NSMutableArray* assistants;

@end
