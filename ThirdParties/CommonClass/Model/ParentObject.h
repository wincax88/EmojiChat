//
//  ParentObject.h
//  iParent
//
//  Created by michael on 13/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Assistant;

@interface ParentObject : NSObject

@property (nonatomic, retain) NSNumber *parentid;       // 家长用户名
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString* nick;           // 昵称
@property (nonatomic, retain) NSString* face;           // 头像地址
@property (nonatomic, retain) NSString* phone;          // 手机号

@property (nonatomic, retain) NSNumber *gender;         // 性别（0 保密 1 男 2 女）


@property (nonatomic, retain) NSMutableArray *children_info;    // 变长数组[9999]	家长的孩子信息
@property (nonatomic, retain) NSMutableArray *ass_info;         // 学生助教信息

// total
@property (nonatomic, retain) NSNumber *order_cnt;      // 未支付订单数
@property (nonatomic, retain) NSNumber *lesson_cnt;     // 未确认课时数
@property (nonatomic, retain) NSNumber *quiz_cnt;       // 未确认测评数

// by student
@property (nonatomic, retain) NSNumber *lesson_finished_cnt;    // 已经完成的课时数
@property (nonatomic, retain) NSNumber *lesson_unfinish_cnt;    // 未完成的课时数
@property (nonatomic, retain) NSNumber *lesson_unconfirm_cnt;   // 未确认课时数
@property (nonatomic, retain) NSNumber *quiz_finished_cnt;      // 已经确认测评数
@property (nonatomic, retain) NSNumber *quiz_unconfirm_cnt;     // 未确认测评数

@end

