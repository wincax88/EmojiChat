//
//  FileObject.h
//  iTao
//
//  Created by stephen on 14-8-12.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILE_STATUS @[@"无", @"未完成", @"已提交", @"已批阅"]

@interface FileObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSNumber* courseid;           // 课程id
@property (nonatomic, copy) NSString* work_intro;           // 作业信息
@property (nonatomic, retain) NSNumber* lesson_num;         // 第几节课
@property (nonatomic, retain) NSNumber* lesson_type;        // 0正常课次，1预约课次
@property (nonatomic, retain) NSNumber* lessonid;           // 课次id
@property (nonatomic, retain) NSNumber* work_status;        // 作业状态（0未上传，1已上传，2学生已提交，3老师已批改）
@property (nonatomic, copy) NSString* file_name;            // 作业名称
@property (nonatomic, retain) NSNumber* upload_time;        // 上传时间
@property (nonatomic, copy) NSString* download_url;         // 下载链接
@property (nonatomic, retain) NSString* score;              // 作业分数

@property (nonatomic, retain) NSNumber* finish_time;
@property (nonatomic, copy) NSString* finish_url;
@property (nonatomic, retain) NSNumber* check_time;
@property (nonatomic, copy) NSString* check_url;
@property (nonatomic, retain) NSNumber* teacherid;
@property (nonatomic, retain) NSNumber* preview_status;
@property (nonatomic, retain) NSString* lesson_name;

@property (nonatomic, retain) NSNumber* work_start;
@property (nonatomic, retain) NSNumber* work_end;

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL needsUpdate;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, copy) NSString* cacheUrl;
@property (nonatomic) float fileSize;
@property (nonatomic) int filePage;
@property (nonatomic) float progress;

@end
