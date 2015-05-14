//
//  Quiz.h
//  iStudent
//
//  Created by stephen on 10/29/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileObject.h"

#define QUIZ_STATUS @[@"未上传", @"已上传", @"未完成", @"已测评", @"已点评"]

typedef enum {
    kQuizUsalExam           = 0,
    kQuizMidtermExam        = 1,
    kQuizFinalExam          = 2,
} kQuizType;

// midterm exam

@interface Quiz : NSObject

@property (nonatomic, retain) NSNumber* quizid;             // 测试id
@property (nonatomic, retain) NSNumber* courseid;           // 课程id
@property (nonatomic, retain) NSNumber* teacherid;          // 老师id
@property (nonatomic, retain) NSNumber* assistantid;        // 助教id
//@property (nonatomic, retain) NSNumber* lesson_num;
//@property (nonatomic, retain) NSNumber* lesson_type;
@property (nonatomic, retain) NSNumber* work_start;         // 测评开始时间
@property (nonatomic, retain) NSNumber* work_end;           // 测评结束时间
@property (nonatomic, copy) NSString* work_intro;           // 作业信息
@property (nonatomic, retain) NSNumber* work_status;        // 作业状态（0未上传，1已上传，2学生已提交，3老师已批改）
@property (nonatomic, retain) NSNumber* work_type;          // 作业类型：0课后作业，1测评
@property (nonatomic, retain) NSNumber* score;              // 作业分数
@property (nonatomic, retain) NSNumber* quiz_num;           // 第几次测评
@property (nonatomic, retain) NSNumber* quiz_type;          // 测评类型0普通，1期中考,2期末考
@property (nonatomic, retain) NSString* quiz_name;          // 测评名称
@property (nonatomic, retain) NSNumber* upload_time;        // 上传时间
@property (nonatomic, retain) NSNumber* parent_confirm;     // 家长对本次可进行确认 0 未确认 1 已经确认

@property (nonatomic, retain) NSString* download_url;
@property (nonatomic, retain) NSString* cacheUrl;


//@property (nonatomic, retain) FileObject* quizFile;

@end

