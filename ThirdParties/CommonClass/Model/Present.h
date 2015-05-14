//
//  Present.h
//  iStudent
//
//  Created by Stephen on 11/26/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Present : NSObject

@property (nonatomic, copy) NSNumber* giftid;
@property (nonatomic, copy) NSString* gift_pic;  // 图片url
@property (nonatomic, copy) NSString* gift_name; // 物品名称
@property (nonatomic, copy) NSString* gift_intro;  // 物品说明
@property (nonatomic, retain) NSNumber* gift_type; // 1实物, 2虚拟物品(phone),3虚拟物品(qq)
@property (nonatomic, retain) NSNumber* primary_praise; //原始需要赞的个数
@property (nonatomic, retain) NSNumber* current_praise; //现在需要赞的个数
@property (nonatomic, retain) NSNumber* gift_flag;  //礼品属性 1普通 2最热 3最多 4最新
@property (nonatomic, retain) NSNumber* gift_status; //	0未上架, 1可兑换,2已下架

@property (nonatomic, retain) NSNumber* timestamp;
@end

@interface MyPresent : NSObject

@property (nonatomic, strong) NSNumber *giftid;
@property (nonatomic, strong) NSNumber *exchangeid;
@property (nonatomic, strong) NSNumber *exchange_time; // 生成时间
@property (nonatomic, strong) NSString *gift_name;
@property (nonatomic, strong) NSString *gift_pic; // 图片url
@property (nonatomic, strong) NSNumber *praise; // 使用多少赞
@property (nonatomic, strong) NSNumber *gift_type; // 1实物, 2虚拟物品(phone),3虚拟物品(qq)
@property (nonatomic, strong) NSNumber *status; // 礼品发放状态 0待处理，1已发货，2已收货, 3已锁定,4已取消
@property (nonatomic, strong) NSString *account; // 姓名
@property (nonatomic, strong) NSString *consignee;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *consignee_phone;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSNumber *exchange_left_day;
@property (nonatomic, strong) NSString *gift_intro;

@end
