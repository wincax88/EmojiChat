//
//  Teacher.h
//  iStudent
//
//  Created by stephen on 10/10/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Teacher : NSObject

@property (nonatomic, retain) NSNumber* teacherid;      // 老师id
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* nick;           // 昵称
@property (nonatomic, retain) NSString* face;           // 头像地址
@property (nonatomic, retain) NSNumber* work_year;      // 工作年限
@property (nonatomic, retain) NSString* title;          // 职称
@property (nonatomic, retain) NSNumber* level;          // 等级5A之类

@property (nonatomic, retain) NSString* base_intro;     // 老师简介
@property (nonatomic, retain) NSNumber* rate_cnt;       // 老师评价个数
@property (nonatomic, retain) NSNumber* rate_score;     // 老师评价分数 [0, 50]
@property (nonatomic, retain) NSNumber* rate_effect;    // 教学效果
@property (nonatomic, retain) NSNumber* rate_quality;   // 老师课件质量
@property (nonatomic, retain) NSNumber* rate_interact;  // 老师课堂互动
@property (nonatomic, retain) NSString* advantage;      // 个人优势

@property (nonatomic, retain) NSString* phone;          // 手机号
@property (nonatomic, retain) NSNumber* gender;         // 性别（0 保密 1 男 2 女）
@property (nonatomic, retain) NSNumber* grade;          // 老师学历
@property (nonatomic, retain) NSString* school;         // 毕业学校
@property (nonatomic, retain) NSString* address;        // 收货地址
@property (nonatomic, retain) NSNumber* birth;          // 生日（格式如19910101）
@property (nonatomic, retain) NSString* lesson_desc;    // 课程描述
@property (nonatomic, retain) NSNumber* tutor_grade;    // 所教的年级
@property (nonatomic, retain) NSNumber* tutor_subject;

@property (nonatomic, retain) NSString* achievement;    // 教学成就，学生成绩
@property (nonatomic, retain) NSString* prize;          // 曾经获取的奖励或者成就
@property (nonatomic, retain) NSMutableArray* quiz_analyse;    // 试题分析,多张图片，以逗号分割
@property (nonatomic, retain) NSMutableArray* quiz_video;      // 试题分析视频，以逗号分割，顺序为封面，笔画，声音
@property (nonatomic, retain) NSString* teacher_style;  // 授课风格

@end

