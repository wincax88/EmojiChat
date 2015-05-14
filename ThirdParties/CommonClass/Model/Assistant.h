//
//  Assistant.h
//  iStudent
//
//  Created by stephen on 10/10/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Assistant : NSObject

@property (nonatomic, retain) NSNumber* assistantid;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, copy) NSString* nick;             // 昵称
@property (nonatomic, copy) NSString* face;             // 头像地址
@property (nonatomic, retain) NSNumber* level;          // 等级5A之类
@property (nonatomic, copy) NSString* school;           // 毕业学校
@property (nonatomic, retain) NSNumber* birth;          // 生日（格式如19910101）
@property (nonatomic, retain) NSString* phone;          // 手机号
@property (nonatomic, retain) NSString* base_intro;     // 老师简介
@property (nonatomic, retain) NSString* advantage;      // 个人优势
@property (nonatomic, retain) NSString* course;         // 所负责课程
@property (nonatomic, retain) NSString* title;          // 职称
@property (nonatomic, retain) NSNumber* rate_score;     // 老师评价分数
@property (nonatomic, retain) NSNumber* rate_attitude;  // 服务态度
@property (nonatomic, retain) NSNumber* rate_kind;      // 亲和程度
@property (nonatomic, retain) NSNumber* rate_effect;    // 教学效果
@property (nonatomic, retain) NSNumber* rate_cnt;       // 评价个数
@property (nonatomic, retain) NSString* lesson_desc;    // 课程描述
@property (nonatomic, retain) NSString* ass_style;      // 带教风格
@property (nonatomic, retain) NSString* prize;          // 曾经获取的奖励或者成就
@property (nonatomic, retain) NSString* achievement;    // 教学成就，学生成绩
@property (nonatomic, retain) NSNumber* work_year;      // 工作年限
@property (nonatomic, retain) NSNumber* tutor_subject;  // 所教的科目
@property (nonatomic, retain) NSNumber* tutor_grade;    // 所教的年级


@end
