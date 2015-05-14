//
//  SalaryObject.h
//  iTeacher
//
//  Created by michael on 3/12/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSalaryCurMonth         = 1,
    kSalaryLatest3Months    = 2,
    kSalaryAll              = 3
} kSalaryDurationType;

// 1 本月 2 近三月 3 全部
@interface SalaryObject : NSObject

@property (nonatomic, strong) NSNumber* incomeid;               // 收入id
@property (nonatomic, strong) NSNumber* income_time;            // 收入时间
@property (nonatomic, strong) NSString* income_type;            // 收入类型 1上课收入,2上课迟到
@property (nonatomic, strong) NSNumber* income_num;             // 元
@property (nonatomic, strong) NSNumber* income_status;          // 收入状态0未确认1已经确认
@property (nonatomic, strong) NSString* income_reason;          // 收入状态0未确认1已经确认
@property (nonatomic, strong) NSNumber* studentid;              // 学生的id
@property (nonatomic, strong) NSString* stu_nick;               // 学生的nick
@property (nonatomic, strong) NSNumber* lessonid;               // lessonid的id

@end
