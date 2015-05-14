//
//  CourseWareObject.h
//  iStudent
//
//  Created by michael on 5/12/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseWareObject : NSObject

@property (nonatomic, retain) NSNumber* courseid;           // 课程id
@property (nonatomic, retain) NSString* download_url;       // 课件下载地址
@property (nonatomic, retain) NSString* file_name;          // 课件名称
@property (nonatomic, retain) NSString* lesson_name;        // 课次名称
@property (nonatomic, retain) NSNumber* lesson_num;         // 第几节课
@property (nonatomic, retain) NSNumber* lessonid;           // 课次id
@property (nonatomic, retain) NSNumber* preview_status;     // 预习状态0未预习，1已预习
@property (nonatomic, retain) NSNumber* upload_time;        // 课件上传时间
@property (nonatomic, retain) NSString* lesson_intro;       // 课次简介（包括知识点之类）

@end
