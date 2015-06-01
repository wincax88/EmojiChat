//
//  NotificationObject.h
//  iChat
//
//  Created by michael on 24/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationObject : NSObject

@property (nonatomic, strong) NSString* senderid;   // 用户的id
@property (nonatomic, strong) NSString* message;    // 消息
@property (nonatomic, strong) NSString* sound;      // 声音
@property (nonatomic, strong) NSNumber* timestamp;  // 收到时间

@end
