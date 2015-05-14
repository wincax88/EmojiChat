//
//  ListRecord.h
//  iStudent
//
//  Created by Stephen on 11/25/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListRecord : NSObject

@property (nonatomic, retain) NSString* orderid;                // 订单编号
@property (nonatomic, retain) NSString* contractid;             // 合同编号
@property (nonatomic, retain) NSNumber* contract_starttime;     // 生效日期
@property (nonatomic, retain) NSNumber* contract_endtime;       // 截止日期
@property (nonatomic, retain) NSNumber* lesson_total;           // 课次总数
@property (nonatomic, retain) NSNumber* order_time;             // 下单时间
@property (nonatomic, retain) NSNumber* grade;                  // 年级
@property (nonatomic, retain) NSNumber* price;                  // 订单价格
@property (nonatomic, retain) NSNumber* order_status;           // 订单状态 0 未支付 1 已支付 2 已取消
@property (nonatomic, retain) NSNumber* userid;                 // 用户账号
@property (nonatomic, retain) NSNumber* pay_time;               // 订单完成时间
@property (nonatomic, retain) NSString* order_desc;             // 订单描述
@property (nonatomic, retain) NSString* order_name;             // 订单名称
@property (nonatomic, retain) NSString* order_type;             // 课程类型
@end
