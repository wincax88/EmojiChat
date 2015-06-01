//
//  AccountObject.h
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kContactInvited     = 1,
    kContactIsFriend    = 2,
    kContactIsInvitee   = 3,
    kContactIsRefused   = 4,
    
} kContactRelationShip;

@interface AccountObject : NSObject

@property (nonatomic, strong) NSString* userid;     // 用户的id
@property (nonatomic, strong) NSString* nick;       // 昵称
@property (nonatomic, strong) NSString* face;       // 头像地址（可以直接使用）
@property (nonatomic, strong) NSString* phone;      // 手机号
@property (nonatomic, strong) NSString* remark;     // 备注信息
@property (nonatomic, strong) NSString* group_name;     // 分组组名
@property (nonatomic, strong) NSString* password;     // 密码
@property (assign, readwrite) kContactRelationShip relationShip;     // 与我的关系

- (NSString*)sortByNickName;

@end
