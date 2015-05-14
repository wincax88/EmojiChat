//
//  Lesson.h
//  iStudent
//
//  Created by stephen on 10/29/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"
#import "Comment.h"
#import "FileObject.h"
#import "CourseWareObject.h"

#define LESSON_STATUS @[@"未开始", @"正常上课", @"已上课", @"课程终结"]
/*
@class Video;
@class Comment;
@class FileObject;
@class CourseWareObject;
*/
@interface Lesson : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSNumber* lessonid;                   // 课次id
@property (nonatomic, retain) NSNumber* courseid;                   // 课程id
@property (nonatomic, retain) NSString* lesson_name;                // 课次名称
@property (nonatomic, retain) NSNumber* lesson_num;                 // 第几节课
@property (nonatomic, retain) NSNumber* lesson_type;                // 0正常课次，1预约课次 1001  可举手  1002  不可举手  1003 1对1
@property (nonatomic, retain) NSNumber* lesson_start;               // 上课开始时间
@property (nonatomic, retain) NSNumber* lesson_end;                 // 上课结束时间
@property (nonatomic, retain) NSString* lesson_intro;               // 课次简介（包括知识点之类）
@property (nonatomic, retain) NSNumber* lesson_status;              // 上课状态（0 未开始 1 课程正在进行 2 本次课结束 3 课程终结）
@property (nonatomic, retain) NSNumber* lesson_left_time;           // 上课剩余时间
@property (nonatomic, retain) NSNumber* is_enterable;

@property (nonatomic, retain) NSNumber* tea_comment_status;
@property (nonatomic, retain) NSNumber* stu_comment_status;

@property (nonatomic, retain) NSNumber* studentid;
@property (nonatomic, retain) NSNumber* teacherid;                  // 老师id
@property (nonatomic, retain) NSNumber* assistantid;                // 助教id
@property (nonatomic, retain) NSNumber* parent_confirm;

@property (nonatomic, retain) CourseWareObject* cw_info;            // 课件信息
@property (nonatomic, retain) Comment* comment_info;                // 评论信息
@property (nonatomic, retain) Video* video_info;                    // 视频信息
@property (nonatomic, retain) FileObject* work_info;                // 作业信息

@property (nonatomic, retain) NSString* teacher_nick;               // 老师名字

@property (nonatomic, retain) Video* video;
@property (nonatomic, retain) Comment* comment;
@property (nonatomic, retain) FileObject* file;
@property (nonatomic, retain) FileObject* homework;

// server info
@property (nonatomic, retain) NSString  *roomid;
@property (nonatomic, retain) NSString  *webrtc;
@property (nonatomic, retain) NSString  *xmpp;
@property (nonatomic, retain) NSString  *webrtc_user;
@property (nonatomic, retain) NSString  *webrtc_password;
@property (nonatomic, retain) NSNumber  *testnet_port;              // 上传下载端口，下载数据为 test.data，上传未/upload.php


@property (nonatomic, retain) NSNumber* current_time;               // server time
@property (nonatomic, retain) NSString* teacher_intro;              // teacher introduction audio url

@property (nonatomic, retain) NSNumber* will_begin_flag;            // notification flag for local using

@property (nonatomic, retain) NSMutableArray* courseFile;

@end

